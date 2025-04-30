IsPynvim = function()
	if vim.g.python3_host_prog == nil then
		return false
	else
		return true
	end
end

