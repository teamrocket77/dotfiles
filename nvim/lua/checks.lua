local M = {}

-- External binaries this config depends on: { bin, why, how }.
M.required = {
	{ bin = "tree-sitter", why = "nvim-treesitter parser builds", how = ":MasonInstall tree-sitter-cli / brew install tree-sitter" },
	{ bin = "cc", why = "compiling treesitter parsers", how = "xcode-select --install" },
	{ bin = "yamlfmt", why = "YAML formatting via conform", how = ":MasonInstall yamlfmt / brew install yamlfmt" },
	{ bin = "yaml-language-server", why = "yamlls / helm_ls schema validation", how = ":MasonInstall yaml-language-server" },
	{ bin = "git", why = "mini.git, git-blame, pickers", how = "brew install git" },
}

-- Nix machine only (signalled by $NIX_PROFILES, same as shell/env.sh).
if (vim.env.NIX_PROFILES or "") ~= "" then
	table.insert(M.required, { bin = "nixd", why = "Nix LSP", how = "provided via nixpkgs / nix profile" })
	table.insert(M.required, { bin = "nixfmt", why = "Nix formatting via conform", how = "provided via nix/dev.nix" })
end

function M.missing()
	local miss = {}
	for _, r in ipairs(M.required) do
		if vim.fn.executable(r.bin) == 0 then
			table.insert(miss, r)
		end
	end
	return miss
end

function M.notify()
	local miss = M.missing()
	if #miss == 0 then
		return
	end
	local lines = { "Missing required binaries:" }
	for _, r in ipairs(miss) do
		table.insert(lines, ("  • %s — %s (%s)"):format(r.bin, r.why, r.how))
	end
	vim.notify(table.concat(lines, "\n"), vim.log.levels.WARN, { title = "nvim deps" })
end

vim.api.nvim_create_user_command("CheckDeps", function()
	if #M.missing() == 0 then
		vim.notify("All required binaries present", vim.log.levels.INFO, { title = "nvim deps" })
	else
		M.notify()
	end
end, { desc = "Report missing external binaries" })

return M
