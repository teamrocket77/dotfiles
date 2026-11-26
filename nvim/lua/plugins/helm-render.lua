-- Helm template rendering helpers, shared by three entry points:
--   * :HelmT    (buffer-local, ftplugin/helm.lua, <leader>hr) — render the
--     CURRENT template buffer.
--   * :HelmPick (global, <leader>hp) — pick a template file first, then values;
--     works from anywhere (e.g. the dashboard), not just inside a helm buffer.
--   * :HelmAll  (buffer-local in repos with devops/helm/*chart/Chart.yaml,
--     <leader>hr outside templates) — render the WHOLE chart, subcharts
--     included, with the current values file (or a picked one).
-- :HelmT and :HelmPick render ONE template with `helm template --show-only`;
-- :HelmAll renders everything. All open the output in a split as an acwrite
-- buffer and hand it to :YamlCrdsAttach so yamlls validates it (something
-- helm_ls's embedded yamlls can't do here).

local M = {}

-- Open rendered `stdout` in a split as an acwrite buffer (writable via :w, but
-- saved only on explicit request), then attach yamlls + the CRD schema.
local function open_rendered(root, chart, rel, stdout)
  local base = vim.fn.fnamemodify(rel, ":t:r")
  -- Name it OUTSIDE any templates/ dir so filename-based ft detection can't force
  -- `helm`; :YamlCrdsAttach sets ft=yaml explicitly regardless.
  local function candidate(n)
    local suffix = n == 1 and "" or ("." .. n)
    return root .. "/" .. chart .. "-" .. base .. suffix .. ".rendered.yaml"
  end
  local name, n = candidate(1), 1
  while vim.fn.bufexists(name) == 1 do
    n = n + 1
    name = candidate(n)
  end

  local buf = vim.api.nvim_create_buf(true, false)
  local lines = vim.split(stdout or "", "\n", { plain = true })
  if lines[#lines] == "" then
    table.remove(lines) -- drop the trailing empty line from the final newline
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_name(buf, name)
  vim.bo[buf].buftype = "acwrite"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false

  -- acwrite needs an autocmd to perform the write: `:w` (or `:w path`) writes the
  -- current lines and clears the modified flag, so nothing lands on disk unasked.
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    callback = function(a)
      local target = (a.match ~= "" and a.match) or vim.api.nvim_buf_get_name(a.buf)
      vim.fn.writefile(vim.api.nvim_buf_get_lines(a.buf, 0, -1, false), target)
      vim.bo[a.buf].modified = false
      vim.notify("helm: wrote " .. target)
    end,
  })

  vim.cmd("botright vsplit")
  vim.api.nvim_win_set_buf(0, buf)
  vim.cmd("YamlCrdsAttach") -- buffer already named -> just sets ft=yaml + attaches
end

-- Values files at the chart root or one level down.
local function values_files(root)
  local out = {}
  for _, g in ipairs({ "values*.yaml", "values*.yml", "*/values*.yaml", "*/values*.yml" }) do
    vim.list_extend(out, vim.fn.glob(root .. "/" .. g, false, true))
  end
  return out
end

-- Run `cmd` (a `helm template ...` argv) and open its output via open_rendered.
local function run_helm(cmd, root, chart, rel)
  vim.system(cmd, { text = true }, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        vim.notify("helm template failed\n" .. (res.stderr or ""), vim.log.levels.ERROR)
        return
      end
      open_rendered(root, chart, rel, res.stdout)
    end)
  end)
end

-- Given a chart root and a chart-root-relative template path, pick a values file
-- (mini.pick, with a synthetic default entry) and render that single template.
function M.render(root, rel)
  if vim.fn.executable("helm") ~= 1 then
    vim.notify("helm not found on PATH", vim.log.levels.ERROR)
    return
  end
  local chart = vim.fn.fnamemodify(root, ":t")

  -- Values files plus a synthetic "default" entry (render with the chart's own
  -- values.yaml, no -f). Escaping cancels.
  local DEFAULT = "<default values.yaml>"
  local items = { DEFAULT }
  vim.list_extend(items, values_files(root))

  require("mini.pick").start({
    source = {
      name = "values for " .. chart,
      items = items,
      choose = function(item)
        if not item then
          return
        end
        -- Defer so the picker tears down before we spawn helm / open a window
        -- (same pattern as open_code_repo / <Space>gup in mini.lua).
        vim.schedule(function()
          local cmd = { "helm", "template", chart, root, "--show-only", rel }
          if item ~= DEFAULT then
            vim.list_extend(cmd, { "-f", item })
          end
          run_helm(cmd, root, chart, rel)
        end)
      end,
    },
  })
end

-- Derive chart root + rel template path from the CURRENT buffer, then render.
-- Backs :HelmT.
function M.render_current()
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    vim.notify("HelmT: current buffer has no file", vim.log.levels.WARN)
    return
  end
  local root = vim.fs.root(path, "Chart.yaml")
  if not root then
    vim.notify("HelmT: not inside a Helm chart (no Chart.yaml ancestor)", vim.log.levels.WARN)
    return
  end
  root = vim.fs.normalize(root)
  local rel = vim.fs.normalize(path):sub(#root + 2) -- e.g. templates/externalsecret.yaml
  M.render(root, rel)
end

-- Pick a Helm template file under `dir` (default cwd), then render it. Global, so
-- it works from the dashboard / anywhere. Two-step picker: template -> values.
-- Backs :HelmPick.
function M.pick_and_render(dir)
  dir = vim.fs.normalize(dir or vim.fn.getcwd())
  require("mini.pick").builtin.cli(
    {
      -- Run find from within `dir` so results are relative (e.g.
      -- chart/templates/foo.yaml) instead of absolute — the cwd prefix never
      -- shows in the picker. choose re-joins `dir` to get the real path.
      command = {
        "find", ".", "-type", "f",
        "-not", "-path", "*/.git/*",
        "-path", "*/templates/*",
        "(", "-name", "*.yaml", "-o", "-name", "*.yml", ")",
      },
      spawn_opts = { cwd = dir },
      postprocess = function(lines)
        local out = {}
        for _, l in ipairs(lines) do
          if l ~= "" then
            out[#out + 1] = (l:gsub("^%./", "")) -- drop find's leading "./"
          end
        end
        return out
      end,
    },
    {
      source = {
        name = "Helm template",
        choose = function(item)
          if not item or item == "" then
            return
          end
          local file = vim.fs.normalize(dir .. "/" .. item)
          local root = vim.fs.root(file, "Chart.yaml")
          if not root then
            vim.notify("HelmPick: " .. item .. " is not inside a Helm chart", vim.log.levels.WARN)
            return
          end
          root = vim.fs.normalize(root)
          local rel = file:sub(#root + 2)
          -- Defer so this picker tears down before render opens the values picker.
          vim.schedule(function()
            M.render(root, rel)
          end)
        end,
      },
    }
  )
end

-- Render the whole chart at `root` with `values` layered over its values.yaml.
-- Subcharts come from the vendored charts/*.tgz, so no `helm dependency build`.
function M.render_all(root, values)
  if vim.fn.executable("helm") ~= 1 then
    vim.notify("helm not found on PATH", vim.log.levels.ERROR)
    return
  end
  local chart = vim.fn.fnamemodify(root, ":t")
  run_helm({ "helm", "template", chart, root, "-f", values }, root, chart, vim.fs.basename(values))
end

-- Charts this file's repo exposes under the devops/helm/*chart convention.
local CHART_GLOB = "devops/helm/*chart/Chart.yaml"
local function repo_charts(path)
  local repo = vim.fs.root(path, ".git")
  if not repo then
    return nil, {}
  end
  local charts = vim.tbl_map(function(f)
    return vim.fs.dirname(f)
  end, vim.fn.glob(repo .. "/" .. CHART_GLOB, false, true))
  return repo, charts
end

-- If the current buffer is a values file inside a chart, render the whole chart
-- with it. Otherwise pick a values file from the repo's devops/helm charts.
-- Backs :HelmAll.
function M.render_all_current()
  local path = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  local root = path ~= "" and vim.fs.root(path, "Chart.yaml")
  if root and vim.fs.basename(path):match("^values.*%.ya?ml$") then
    M.render_all(vim.fs.normalize(root), path)
    return
  end

  local repo, charts = repo_charts(path ~= "" and path or vim.fn.getcwd())
  local items = {}
  for _, c in ipairs(charts) do
    for _, f in ipairs(values_files(c)) do
      items[#items + 1] = vim.fs.normalize(f):sub(#repo + 2) -- e.g. devops/helm/x-chart/values-dev.yaml
    end
  end
  if #items == 0 then
    vim.notify("HelmAll: no " .. CHART_GLOB .. " values files in this repo", vim.log.levels.WARN)
    return
  end

  require("mini.pick").start({
    source = {
      name = "values (render all)",
      items = items,
      choose = function(item)
        if not item then
          return
        end
        local file = repo .. "/" .. item
        vim.schedule(function()
          M.render_all(vim.fs.normalize(vim.fs.root(file, "Chart.yaml")), file)
        end)
      end,
    },
  })
end

-- Enable :HelmAll + <leader>hr in any file of a repo that follows the
-- devops/helm/*chart convention. Template buffers (ft=helm) keep the
-- single-template <leader>hr from ftplugin/helm.lua (which overwrites this one
-- if filetype detection runs after us).
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("helm_render_all", { clear = true }),
  callback = function(args)
    local path = vim.api.nvim_buf_get_name(args.buf)
    if path == "" or vim.bo[args.buf].buftype ~= "" or #select(2, repo_charts(path)) == 0 then
      return
    end
    vim.api.nvim_buf_create_user_command(args.buf, "HelmAll", function()
      M.render_all_current()
    end, { desc = "Render the whole Helm chart with this (or a picked) values file" })
    if vim.bo[args.buf].filetype ~= "helm" then
      vim.keymap.set("n", "<leader>hr", function()
        M.render_all_current()
      end, { buffer = args.buf, desc = "HelmAll: render the whole chart with this/picked values" })
    end
  end,
})

vim.api.nvim_create_user_command("HelmPick", function()
  M.pick_and_render()
end, { desc = "Pick a Helm template + values, render (--show-only) and validate against its CRD schema" })

vim.keymap.set("n", "<leader>hp", function()
  M.pick_and_render()
end, { desc = "HelmPick: pick template + values, render + validate" })

return M
