-- Per-buffer CRD schema attachment for yamlls, backed by a local mirror of
-- datreeio/CRDs-catalog.
--
-- * Opening a Helm chart template (FileType helm, under templates/) lazily
--   downloads the full catalog into the cache once (~20MB pull, ~215MB on disk).
-- * Opening a plain YAML k8s doc (FileType yaml) detects its apiVersion/kind and
--   attaches the matching cached CRD schema to *that buffer only*, falling back
--   to yamlls' bundled `kubernetes` schema for built-in kinds. No network at
--   edit time once the cache is warm.
--
-- Cache lives at stdpath("cache")/yaml-crds (XDG_CACHE_HOME, not the repo).
-- Force a refresh (e.g. to pick up new upstream CRDs) with :YamlCrdsSync.
--
-- Note: this warms the cache for plain-yaml manifests. Validating CRDs *inside*
-- Helm templates still needs a `# yaml-language-server: $schema=` modeline or a
-- glob mapping in helm_config (helm_ls runs its own embedded yamlls).

local M = {}

M.cache_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "yaml-crds")
M.catalog_url = "https://github.com/datreeio/CRDs-catalog/archive/refs/heads/main.tar.gz"

local ready_marker = vim.fs.joinpath(M.cache_dir, ".ready")

-- Catalog present and fully extracted (marker written only on success).
local function catalog_ready()
  return vim.uv.fs_stat(ready_marker) ~= nil
end

-- Re-run schema attach for every loaded plain-yaml buffer (used after a fresh
-- download so open buffers pick up schemas without a reopen).
local function reattach_open_yaml()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "yaml" then
      vim.b[buf].crd_schema_attached = nil
      M.init(buf)
    end
  end
end

-- Download + extract the whole catalog into the cache, async and idempotent.
-- force=true re-pulls even if already present (:YamlCrdsSync).
function M.ensure_catalog(force)
  if M._downloading then
    return
  end
  if catalog_ready() and not force then
    return
  end
  M._downloading = true
  vim.fn.mkdir(M.cache_dir, "p")

  -- Strip the top-level <repo>-main/ dir so files land at <cache>/<group>/...,
  -- exactly the layout crd_schema() reads. Marker written last, only on success.
  local script = string.format(
    "rm -f %q && curl -fsSL %q | tar -xz -f - --strip-components=1 -C %q && touch %q",
    ready_marker, M.catalog_url, M.cache_dir, ready_marker
  )
  vim.notify("yaml-crds: downloading CRD catalog (~20MB)…", vim.log.levels.INFO)
  vim.system({ "bash", "-c", script }, { text = true }, function(res)
    M._downloading = false
    vim.schedule(function()
      if res.code == 0 then
        vim.notify("yaml-crds: CRD catalog ready", vim.log.levels.INFO)
        reattach_open_yaml()
      else
        vim.notify("yaml-crds: catalog download failed\n" .. (res.stderr or ""), vim.log.levels.ERROR)
      end
    end)
  end)
end

-- First apiVersion/kind in the buffer. yamlls binds one schema per file, so a
-- multi-doc file is keyed off its first document (same limitation as globs).
local function extract_gvk(bufnr)
  local api_version, kind
  for _, line in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 200, false)) do
    api_version = api_version or line:match("^apiVersion:%s*([%w%.%-/]+)")
    kind = kind or line:match("^kind:%s*([%w%-]+)")
    if api_version and kind then
      break
    end
  end
  return api_version, kind
end

-- Local cache path for a CRD's schema, or nil if this GVK isn't a cached CRD.
local function crd_schema(api_version, kind)
  local group, version = api_version:match("^([^/]+)/([^/]+)$")
  if not group then
    return nil -- core group (e.g. v1): handled by the bundled kubernetes schema
  end
  local path = vim.fs.joinpath(M.cache_dir, group, kind:lower() .. "_" .. version .. ".json")
  return vim.uv.fs_stat(path) and path or nil
end

-- Map `schema` to `bufpath` on the yamlls client, scoped to that one file. Keeps
-- existing mappings (gitlab schema, other buffers' CRDs) intact.
local function map_schema(client, schema, bufpath)
  client.config.settings = client.config.settings or {}
  local yaml = client.config.settings.yaml or {}
  client.config.settings.yaml = yaml
  yaml.schemas = yaml.schemas or {}

  local cur = yaml.schemas[schema]
  if type(cur) == "string" then
    cur = { cur }
  elseif cur == nil then
    cur = {}
  end
  if not vim.tbl_contains(cur, bufpath) then
    table.insert(cur, bufpath)
  end
  yaml.schemas[schema] = cur

  client:notify("workspace/didChangeConfiguration", { settings = client.config.settings })
end

function M.init(bufnr)
  if vim.b[bufnr].crd_schema_attached then
    return
  end

  local api_version, kind = extract_gvk(bufnr)
  if not (api_version and kind) then
    return -- not a k8s-style document
  end

  local client = vim.lsp.get_clients({ name = "yamlls", bufnr = bufnr })[1]
  if not client then
    return
  end

  local bufpath = vim.api.nvim_buf_get_name(bufnr)
  if bufpath == "" then
    return
  end

  -- Prefer a cached CRD schema; otherwise let the bundled kubernetes schema
  -- validate built-in kinds. Both scoped to this buffer's path.
  local schema = crd_schema(api_version, kind) or "kubernetes"
  map_schema(client, schema, bufpath)
  vim.b[bufnr].crd_schema_attached = true
end

local group = vim.api.nvim_create_augroup("yaml_crds", { clear = true })

-- Plain YAML k8s docs: attach the matching schema per buffer.
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "yaml",
  callback = function(args)
    local bufnr = args.buf
    if vim.lsp.get_clients({ name = "yamlls", bufnr = bufnr })[1] then
      M.init(bufnr)
    else
      -- yamlls not attached yet: run once it does, for this buffer only.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = group,
        buffer = bufnr,
        callback = function(a)
          local c = vim.lsp.get_client_by_id(a.data.client_id)
          if c and c.name == "yamlls" then
            M.init(bufnr)
            return true -- one-shot: delete this LspAttach autocmd
          end
        end,
      })
    end
  end,
})

-- Helm chart templates (devops/**/*/templates/*.yaml -> FileType helm): use the
-- first template you open in a session as the signal to warm the catalog cache.
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = "helm",
  callback = function(args)
    local path = vim.api.nvim_buf_get_name(args.buf)
    if path:match("/templates/") then
      M.ensure_catalog(false)
    end
  end,
})

-- Files under the cache are downloaded catalog artifacts, not meant to be edited:
-- open them read-only, however they're opened (:YamlCrdsFind/Grep or otherwise).
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  group = group,
  callback = function(args)
    local name = vim.api.nvim_buf_get_name(args.buf)
    if name == "" then
      return
    end
    local root = vim.fs.normalize(M.cache_dir)
    if vim.fs.normalize(name):sub(1, #root + 1) == root .. "/" then
      vim.bo[args.buf].modifiable = false
      vim.bo[args.buf].readonly = true
    end
  end,
})

vim.api.nvim_create_user_command("YamlCrdsSync", function()
  M.ensure_catalog(true)
end, { desc = "Download/refresh the datreeio CRD schema cache" })

-- Browse the cached CRD schemas with mini.pick.
local function cache_or_warn()
  if vim.fn.isdirectory(M.cache_dir) == 0 then
    vim.notify("CRD cache is empty — run :YamlCrdsSync", vim.log.levels.WARN)
    return nil
  end
  return M.cache_dir
end

vim.api.nvim_create_user_command("YamlCrdsFind", function()
  local dir = cache_or_warn()
  if dir then
    require("mini.pick").builtin.files({}, { source = { cwd = dir, name = "CRD schemas" } })
  end
end, { desc = "Find a cached CRD schema by filename" })

vim.api.nvim_create_user_command("YamlCrdsGrep", function()
  local dir = cache_or_warn()
  if dir then
    require("mini.pick").builtin.grep_live({}, { source = { cwd = dir, name = "Grep CRD schemas" } })
  end
end, { desc = "Live-grep inside cached CRD schemas" })

return M
