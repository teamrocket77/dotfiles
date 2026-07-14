vim.pack.add({
	{
		src = "https://github.com/mfussenegger/nvim-dap.git",
		version = "6a5bba0ddea5d419a783e170c20988046376090d",
	},
	{
		src = "https://github.com/rcarriga/nvim-dap-ui.git",
		version = "f7d75cca202b52a60c520ec7b1ec3414d6e77b0f",
	},
	{
		src = "https://github.com/nvim-neotest/nvim-nio",
		version = "21f5324bfac14e22ba26553caf69ec76ae8a7662",
	}
})

local dap = require("dap")
local dapui = require("dapui")
vim.keymap.set("n", "<leader>b", function()
	dap.toggle_breakpoint()
end)
vim.keymap.set("n", "<leader><Right>", function()
	dap.continue()
end)
vim.keymap.set("n", "<leader><Up>", function()
	dap.step_over()
end)
vim.keymap.set("n", "<leader><Down>", function()
	dap.step_into()
end)
vim.keymap.set("n", "<leader><Left>", function()
	dap.step_out()
end)
vim.keymap.set("n", "<leader>dr", function()
	dap.repl.open()
end)
vim.keymap.set("n", "<leader>s<Left>", function()
	dap.repl.open()
end)

dapui.setup()
dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end
dap.adapters.lldb = {
	type = "executable",
	command = "/opt/homebrew/opt/llvm/bin/lldb-dap", -- required to be absolute path
	name = "lldb",
}
-- https://github.com/llvm/llvm-project/blob/main/lldb/tools/lldb-dap/README.md
local current_dir = "Path to executable: " .. vim.fn.getcwd() .. "/"
local c_cpp_dap_config = {
	{
		request = "launch",
		name = "launch",
		type = "lldb",
		program = function()
			return vim.fn.input(current_dir)
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
		args = {},
	},
}
dap.configurations.cpp = c_cpp_dap_config
dap.configurations.c = c_cpp_dap_config
