return {
  "jedrzejboczar/possession.nvim",
  requires = { "nvim-lua/plenary.nvim" },
  commit = "8fb21fa",
  config = function()
    local session_dir = os.getenv("HOME") .. "/.config/nvim/sessions/"
    local most_recent_session = session_dir .. "recent-session.txt"
    local max_line_length = 5
    require("possession").setup({
      session_dir = session_dir,
      autosave = {
        current = function(name)
          local home = os.getenv("HOME")
          if name == "~" or name == home then
            return false
          end
          return true
        end,
        cwd = true,
        on_quit = true
      },
      hooks = {
        after_save = function(name)
          local line_count = 0
          local file_lines = {}
          local current_obj_val = -1
          local file = io.open(most_recent_session, "r+")
          -- file isn't there and we can't make it
          if file == nil then
            file = io.open(most_recent_session, "w")
            if file == nil then
              return
            end
          end

          for line in file:lines() do
            table.insert(file_lines, line)
            line_count = line_count + 1
            if line == name then
              current_obj_val = line_count
            end
          end

          if current_obj_val > 0 then
            table.remove(file_lines, current_obj_val)
          else
            if line_count >= max_line_length then
              table.remove(file_lines, max_line_length)
            end
            table.insert(file_lines, 1, name)

            local file_seek = file:seek("set")
            if file_seek ~= 0 then
              vim.schedule_wrap(vim.print("Unable to restore seek position to byte 0, got " .. tostring(file_seek)))
            end

            for i, line in ipairs(file_lines) do
              if i >= max_line_length then
                break
              end
              file:write(line .. "\n")
            end
            file:close()
          end
        end
      },
      commands = {
        save = "SSave",
        load = "SLoad",
        delete = "SDelete",
        list = "SList",
      },
    })
    vim.api.nvim_set_keymap("n", "<C-s>", ":PossessionSaveCwd<CR>", { noremap = true, silent = true })
  end
}
