return {
  "mbbill/undotree",
  commit = "b951b87",
  config = function()
    vim.keymap.set("n", "<leader>utog", vim.cmd.UndotreeToggle)
    vim.keymap.set("n", "<leader>ushow", vim.cmd.UndotreeToggle)
    local exists = function(fd)
      local f = io.open(fd, "r")
      if f then
        f:close()
        return true
      end
      return false
    end

    local undo_dir = os.getenv("HOME") .. "/.undodir"
    local e = exists(undo_dir)
    if not e then
      vim.fn.mkdir(undo_dir, "p")
    end
    if e then
      vim.opt.undodir = undo_dir
      vim.opt.undofile = true
    end
  end,
}
