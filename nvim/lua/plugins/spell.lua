return {
  --  https://learnvimscriptthehardway.stevelosh.com/
  "kamykn/spelunker.vim",
  commit = "a0bc530",
  lazy = false,
  ft = "*",
  config = function()
    local g = vim.g
    local api = vim.api
    g.spelunker_max_suggest_words = 10
    g.enable_spelunker_vim = 1
    g.enable_spelunker_vim_on_readonly = 1
    g.spelunker_disable_uri_checking = 1
    g.spelunker_disable_email_checking = 1
    g.spelunker_disable_backquoted_checking = 1
  end,
}
