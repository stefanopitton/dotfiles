local icons = require("stepit.utils.icons")

local languages = {
	"astro",
	"bash",
	"c",
	"css",
	"diff",
	"dockerfile",
	"go",
	"gomod",
	"gowork",
	"gosum",
	"gotmpl",
	"html",
	"javascript",
	"just",
	"json",
	"jsonnet",
	"latex",
	"lua",
	"make",
	"markdown",
	"markdown_inline",
	"python",
	"regex",
	"solidity",
	"toml",
	"typescript",
	"rust",
	"vim",
	"vimdoc",
	"yaml",
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main", -- pinned explicitly: `master` is archived and Neovim 0.11-only
		build = ":TSUpdate",
		-- The `main` rewrite does not support lazy-loading.
		lazy = false,
		dependencies = {
			{
				"nvim-treesitter/nvim-treesitter-context",
				opts = {
					separator = icons.blocks.upper_one,
					max_lines = 3,
					multiline_threshold = 1,
					min_window_height = 20,
				},
				keys = {
					{
						"[c",
						function()
							require("treesitter-context").go_to_context(vim.v.count1)
						end,
						{ desc = "Jump to upper [C]ontext" },
					},
				},
			},
		},
		config = function()
			local ts = require("nvim-treesitter")

			ts.setup({})
			ts.install(languages)

			vim.treesitter.language.register("markdown", "mdx")

			-- `highlight`, `indent` and `ensure_installed` are gone on `main`: highlighting
			-- is started per buffer, and missing parsers are fetched on demand (the old
			-- `autoinstall = true`). Indentation stays off, as it was before.
			local available = {}
			for _, lang in ipairs(ts.get_available()) do
				available[lang] = true
			end
			local pending = {}

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("stepit_treesitter", { clear = true }),
				callback = function(args)
					local lang = vim.treesitter.language.get_lang(args.match)
					if not lang then
						return
					end
					if pcall(vim.treesitter.language.inspect, lang) then
						pcall(vim.treesitter.start, args.buf, lang)
						return
					end
					if not available[lang] or pending[lang] then
						return
					end
					pending[lang] = true
					ts.install(lang):await(function()
						vim.schedule(function()
							if vim.api.nvim_buf_is_valid(args.buf) then
								pcall(vim.treesitter.start, args.buf, lang)
							end
						end)
					end)
				end,
			})
		end,
	},
}
