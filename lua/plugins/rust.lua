return {
  {
    "mrcjkb/rustaceanvim", version = "4.6.0",
    ft = {'rust'}, config = function()
      local fmtRust = function()
        local buf = vim.api.nvim_buf_get_name(0)
        vim.fn.system("rustfmt " .. buf)
        vim.cmd('e!')
      end
      local function build_test_run_cargo_build(action)
        local handle = io.popen('cargo '.. action ..' 2>&1', 'r') -- Run cargo build and capture stdout and stderr
        local result = handle:read("*a") -- Read the entire output
        handle:close()

        -- Create a new buffer and set its lines to the command output
        vim.cmd("new")

        vim.bo.buftype = "nofile"
        vim.bo.bufhidden = "wipe"
        vim.bo.swapfile = false
        vim.bo.readonly = true

        vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(result, "\n"))
      end

      function cargo_build()
        build_test_run_cargo_build("build")
      end

      function cargo_test()
        build_test_run_cargo_build("test")
      end

      function cargo_run()
        build_test_run_cargo_build("run")
      end
      vim.keymap.set("n", "<leader>a", function() vim.cmd.RustLsp('codeAction') end)
      vim.keymap.set("n", "<leader>run", function() cargo_run() end)
      vim.keymap.set("n", "<leader>test", function() cargo_test() end)
      vim.keymap.set("n", "<leader>bu", function() cargo_build() end)
      vim.api.nvim_create_autocmd({"BufWritePost"}, {
        pattern = "*.rs",
        callback = fmtRust
      })
    end

  }
}
