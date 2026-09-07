local M = {}

function M.check()
	vim.health.start("External binaries")
	for _, r in ipairs(require("checks").required) do
		if vim.fn.executable(r.bin) == 1 then
			vim.health.ok(r.bin .. " found")
		else
			vim.health.error(r.bin .. " missing — " .. r.why, { r.how })
		end
	end
end

return M
