-- Helm template rendering helpers, shared by two entry points:
--   * :HelmT    (buffer-local, ftplugin/helm.lua, <leader>hr) — render the
--     CURRENT template buffer.
--   * :HelmPick (global, <leader>hp) — pick a template file first, then values;
--     works from anywhere (e.g. the dashboard), not just inside a helm buffer.
-- Both end the same way: render ONE template to concrete YAML with
-- `helm template --show-only`, open it in a split as an acwrite buffer, and hand
-- it to :YamlCrdsAttach so the datreeio CRD schema validates it (something
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

-- Given a chart root and a chart-root-relative template path, pick a values file
-- (mini.pick, with a synthetic default entry) and render that single template.
function M.render(root, rel)
  if vim.fn.executable("helm") ~= 1 then
    vim.notify("helm not found on PATH", vim.log.levels.ERROR)
    return
  end
  local chart = vim.fn.fnamemodify(root, ":t")

  -- Values files at the chart root or one level down, plus a synthetic "default"
  -- entry (render with the chart's own values.yaml, no -f). Escaping cancels.
  local DEFAULT = "<default values.yaml>"
  local items = { DEFAULT }
  for _, g in ipairs({ "values*.yaml", "values*.yml", "*/values*.yaml", "*/values*.yml" }) do
    vim.list_extend(items, vim.fn.glob(root .. "/" .. g, false, true))
  end

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
          vim.system(cmd, { text = true }, function(res)
            vim.schedule(function()
              if res.code ~= 0 then
                vim.notify("helm template failed\n" .. (res.stderr or ""), vim.log.levels.ERROR)
                return
              end
              open_rendered(root, chart, rel, res.stdout)
            end)
          end)
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
  dir = dir or vim.fn.getcwd()
  require("mini.pick").builtin.cli(
    {
      command = {
        "find", dir, "-type", "f",
        "-not", "-path", "*/.git/*",
        "-path", "*/templates/*",
        "(", "-name", "*.yaml", "-o", "-name", "*.yml", ")",
      },
    },
    {
      source = {
        name = "Helm template",
        choose = function(item)
          if not item or item == "" then
            return
          end
          local file = vim.fs.normalize(item)
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

vim.api.nvim_create_user_command("HelmPick", function()
  M.pick_and_render()
end, { desc = "Pick a Helm template + values, render (--show-only) and validate against its CRD schema" })

vim.keymap.set("n", "<leader>hp", function()
  M.pick_and_render()
end, { desc = "HelmPick: pick template + values, render + validate" })

return M
