---@type vim.lsp.Config
return {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc", "lazy-lock.json", ".git" },
	settings = {
		Lua = {
			completion = { callSnippet = "Replace" },
			format = { enable = true },
			hint = {
				enable = true,
				arrayIndex = "Disable",
			},
			runtime = {
				version = "LuaJIT",
				-- Resolve `require("stepit.foo")` to `lua/stepit/foo.lua`.
				path = { "lua/?.lua", "lua/?/init.lua" },
			},
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
				},
			},
		},
	},
}
