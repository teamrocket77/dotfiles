local normalize_list = function(t)
  local normalized = {}
  for _, v in pairs(t) do
    if v ~= nil then
      table.insert(normalized, v)
    end
  end
  return normalized
end

return {
  "folke/snacks.nvim",
  commit = "5eac729",
  priority = 1000,
  lazy = false,
  opts = {
    lazygit = { enabled = true },
    rename = { enabled = true },
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      sections = {
        { section = "header" },
        { icon = " ", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
        { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1, limit = 5, pane = 2 },
        {
          icon = " ",
          title = "Projects",
          section = "projects",
          indent = 2,
          padding = 2,
          pane = 2,
          limit = 5,
          action = function(dir)
            vim.notify(dir)
            local home = os.getenv("HOME")
            local cur_dir = dir:gsub(home, "~")
            local change_dir_cmd = ("cd %s | "):format(dir)
            local load_session_cmd = ("PossessionLoad %s"):format(cur_dir)
            vim.cmd(change_dir_cmd .. load_session_cmd)
          end
        },
        { section = "startup" },
      },
      preset = {
        keys = {
          { key = "e", icon = "", desc = "New file", action = ":ene | startinsert" },
          { key = "g", icon = " ", desc = "Find Text", action = function() require("snacks").picker.grep() end },
          { key = "f", icon = " ", desc = "Find Files", action = function() require("snacks").picker.files() end },
          { key = "c", icon = " ", desc = "Edit NVIM Config", action = ":cd ~/.config | :PossessionLoad ~/.config" },
          { key = "r", icon = " ", desc = "Edit Zsh file", action = ":cd ~/ | :e ~/.zshrc" },
          function()
            local home = os.getenv("HOME")
            local config = "/.aws/config"
            local f = io.open(home .. config, "r")
            if f ~= nil then
              return { key = "a", icon = "", desc = "View AWS config file", action = ":view " .. home .. config }
            else
              return {}
            end
          end,
          { key = "l", icon = "󰒲", desc = "Lazy", action = ":Lazy" },
          function()
            local home = os.getenv("HOME")
            if home == nil then
              return {}
            end
            local cur_dir = vim.fn.getcwd()
            local possession = require("possession.session")
            local found = false
            local list = possession.list()
            local val = ""
            for k, _ in pairs(list) do
              val = list[k]["name"]
              val = val:gsub("~", home)
              if val == cur_dir then
                found = true
                break
              end
            end
            local session = cur_dir:gsub(home, "~")
            if found then
              return {
                key = "z",
                desc = "Load CWD session ",
                action = ":cd " .. cur_dir .. "| " .. ":PossessionLoad " ..
                    session,
                indent = 2
              }
            end
            return {}
          end,
        },
      }
    },
    indent = {
      enabled = true,
    },
    scope = { enabled = true, },
    notifier = {
      enabled = true,
      timeout = 1000
    },
  },
  keys = {
    { "<leader><space>", function() require("snacks").picker.smart() end,            desc = "Opens Snacks Picker" },
    { "<leader>gf",      function() require("snacks").picker.grep() end,             desc = "Grep" },
    { "<leader>ff",      function() require("snacks").picker.files() end,            desc = "Find Files" },
    { "<leader>gb",      function() require("snacks").picker.grep_buffers() end,     desc = "Grep Buffers" },
    { "gd",              function() require("snacks").picker.lsp_definitions() end,  desc = "LSP Definition" },
    { "gD",              function() require("snacks").picker.lsp_declarations() end, desc = "LSP Declerations" },
    {
      "<leader>gp",
      function()
        local items               = {}
        local possession          = require("possession")
        local possession_sessions = possession.list()
        local longest_name        = 0
        local idx                 = 1
        for k, _ in pairs(possession_sessions) do
          local name = possession_sessions[k]["name"]
          table.insert(items, {
            idx = idx,
            score = idx,
            text = name,
            name = name,
          })
          longest_name = math.max(longest_name, string.len(name))
          idx = idx + 1
        end
        vim.print(vim.inspect(items))
        local snacks = require("snacks")
        snacks.picker({
          items = items,
          format = function(item)
            local ret = {}
            ret[#ret + 1] = { ("%-" .. longest_name .. "s"):format(item.name), "SnacksPickerLabel" }
            ret[#ret + 1] = { item.text, "SnacksPickerComment" }
            return ret
          end,
          confirm = function(picker, item)
            picker:close()
            local change_dir_cmd = ("cd %s | "):format(item.name)
            local load_session_cmd = ("PossessionLoad %s"):format(item.name)
            vim.cmd(change_dir_cmd .. load_session_cmd)
          end,
        })
      end,
      desc = "Session Picker"
    },
    {
      "<leader>ghar",
      function()
        local snacks = require("snacks")
        local harpoon = require("harpoon")
        snacks.picker({
          finder = function()
            local file_paths = {}
            local list = normalize_list(harpoon:list().items)
            for _, item in ipairs(list) do
              table.insert(file_paths, { text = item.value, file = item.value })
            end
            return file_paths
          end,
          win = {
            input = {
              keys = { ["dd"] = { "harpoon_delete", mode = { "n", "x" } } },
            },
            list = {
              keys = { ["dd"] = { "harpoon_delete", mode = { "n", "x" } } },
            },
          },
          actions = {
            harpoon_delete = function(picker, item)
              local to_remove = item or picker:selected()
              harpoon:list():remove({ value = to_remove.text })
              harpoon:list().items = normalize_list(harpoon:list().items)
              picker:find({ refresh = true })
            end,
          },
        })
      end,
      desc = "Get Harpoon files"
    },
    { "<leader>gls", function() require("snacks").picker.lsp_symbols() end,           desc = "LSP Symbols" },
    { "<leader>gws", function() require("snacks").picker.lsp_workspace_symbols() end, desc = "LSP Symbols for Workspace" },
    { "<leader>ql",  function() require("snacks").picker.qflist() end,                desc = "Quickfix List open" },
  },
  init = function()
    local Snacks = require("snacks")
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        _G.dd = function(...)
          Snacks.debug.inspect(...)
        end
        _G.bt = function()
          Snacks.debug.backtrace()
        end
        vim.print = _G.dd
        Snacks.toggle.treesitter():map("<leader>uT")
      end
    })
    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesActionRename",
      callback = function(event)
        Snacks.rename.on_rename_file(event.data.from, event.data.to)
      end,
    })
    vim.api.nvim_create_user_command("ObjInspector", function()
      vim.api.nvim_feedkeys(':lua require("snacks").notify(vim.inspect(x), {timeout = 0, ft="y"})', "n", false)
      -- currently cannot pass tables
    end, { desc = "Writes most of the stuff required for the vim inspect to work with snacks" })
  end
}
