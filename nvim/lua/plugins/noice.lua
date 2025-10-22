return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    cmdline = { enabled = true },
    popupmenu = { enabled = true },
    notify = { enabled = false },
    messages = { enabled = false, },
    lsp = {
      progress = { enabled = false },
      enabled = false,
      hover = { enabled = false },
      override = {
        ["cmp.entry.get_documentation"] = true
      }
    },
  },
  presets = {
    lsp_doc_border = false,   -- add a border to hover docs and signature help
  },
}
