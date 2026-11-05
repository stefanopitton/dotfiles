return {
	"saghen/blink.cmp",
	event = "InsertEnter",
	dependencies = {
		"rafamadriz/friendly-snippets",
		{ "L3MON4D3/LuaSnip", version = "v2.*" },
	},
	version = "1.*",
	config = function()
		require("blink.cmp").setup({
			keymap = {
				preset = "default",
				["<C-y>"] = { "accept", "fallback" },
				-- Jupyter/IDE style <Tab>: cycle the menu when it is open, jump
				-- snippet placeholders, otherwise open the menu when there is a
				-- non-blank character right before the cursor. Only at an indent
				-- (or on empty space) does it fall back to a real tab.
				["<Tab>"] = {
					-- Inside a snippet with a next placeholder, <Tab> always jumps
					-- (closing the menu) so it never cycles stray completions.
					-- Use <C-n>/<C-p> to navigate the menu while in a snippet.
					function(cmp)
						if cmp.snippet_active({ direction = 1 }) then
							cmp.hide()
							return cmp.snippet_forward()
						end
					end,
					function(cmp)
						if cmp.is_visible() then
							return cmp.select_next()
						end
					end,
					function(cmp)
						local col = vim.api.nvim_win_get_cursor(0)[2]
						if vim.api.nvim_get_current_line():sub(1, col):match("%S$") then
							cmp.show()
							return true
						end
					end,
					"fallback",
				},
				["<S-Tab>"] = {
					function(cmp)
						if cmp.snippet_active({ direction = -1 }) then
							cmp.hide()
							return cmp.snippet_backward()
						end
					end,
					function(cmp)
						if cmp.is_visible() then
							return cmp.select_prev()
						end
					end,
					"fallback",
				},
			},

			appearance = {
				nerd_font_variant = "mono",
			},
			completion = {
				documentation = { auto_show = true },
				menu = {
					auto_show = true,
					draw = {
						columns = {
							{ "kind_icon" },
							{ "label", "label_description" },
							{ "kind", "source_name", gap = 5 },
						},
					},
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				per_filetype = {
					python = { "lsp", "python_aliases", "path", "snippets", "buffer" },
				},
				providers = {
					lsp = {
						name = "LSP",
						module = "blink.cmp.sources.lsp",
						score_offset = 1000,
					},
					python_aliases = {
						name = "PyAlias",
						module = "stepit.sources.python_aliases",
						-- Must outrank `lsp` above.
						score_offset = 1100,
					},
					snippets = {
						name = "Snippets",
						module = "blink.cmp.sources.snippets",
						score_offset = 500,
						max_items = 5,
					},
					path = {
						name = "Path",
						module = "blink.cmp.sources.path",
						score_offset = 300,
						max_items = 5,
					},
					buffer = {
						name = "Buffer",
						module = "blink.cmp.sources.buffer",
						score_offset = 100,
						max_items = 5,
					},
				},
			},
			signature = { enabled = true },
			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "prefer_rust_with_warning" },
		})
	end,
}
