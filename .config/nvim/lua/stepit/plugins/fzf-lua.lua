local citations = require("stepit.custom.markdown.citations")

-- Helper to close mini.files before opening fzf-lua
local function close_mini_files()
	local ok, mini_files = pcall(require, "mini.files")
	if ok then
		mini_files.close()
	end
end

return {
	"ibhagwan/fzf-lua",
	lazy = false,
	keys = {
		{
			"<leader>ff",
			function()
				close_mini_files()
				require("fzf-lua").files({
					cwd_prompt = false,
					previewer = "builtin",
				})
			end,
			desc = "[F]ind [F]iles",
		},
		{
			"<leader>fo",
			function()
				require("fzf-lua").oldfiles({
					cwd_only = true,
					include_current_session = true, -- includes files visited during current session.
				})
			end,
			desc = "[F]ind [O]ld files",
		},
		{
			"<leader>fc",
			function()
				local content = citations.get_references_file()
				if not content or content == "" then
					vim.notify("Bibliography file is empty" .. content, vim.log.levels.WARN)
					return
				end

				local parsed_references = citations.parse_references(content)
				local summary = parsed_references.summary
				local entries = parsed_references.entries
				local summary_to_citekey = parsed_references.summary_to_citekey

				-- Case in which the reference file is empty after parsing.
				if #summary == 0 then
					vim.notify("No entries parsed from reference file", vim.log.levels.WARN)
					return
				end

				-- Create a fzf-lua previewer: https://github.com/ibhagwan/fzf-lua/wiki/Advanced#neovim-builtin-preview
				local builtin = require("fzf-lua.previewer.builtin")
				local BibPreview = builtin.base:extend()

				function BibPreview:new(o, opts, fzf_win)
					BibPreview.super.new(self, o, opts, fzf_win)
					setmetatable(self, BibPreview)
					return self
				end

				-- entry_str is what the user select from the fzf UI.
				function BibPreview:populate_preview_buf(entry_str)
					local ref = summary_to_citekey[entry_str]

					local text
					if not ref then
						text = "(no match for line)\n" .. entry_str
					else
						text = citations.bib_to_text(ref)
					end

					local buf = self:get_tmp_buffer()

					vim.api.nvim_buf_set_lines(buf, 0, 2, false, { "BibTex reference:", "" })
					vim.api.nvim_buf_set_lines(buf, 3, -1, false, vim.split(text, "\n", { plain = true }))

					vim.bo[buf].filetype = "bib" -- enable color hi for bib files.
					self:set_preview_buf(buf)
					self.win:update_preview_scrollbar()
				end

				function BibPreview:gen_winopts()
					return vim.tbl_extend("force", self.winopts, { wrap = true, number = false })
				end

				require("fzf-lua").fzf_exec(summary, {
					prompt = require("stepit.utils.icons").symbols.lens .. "    ",
					previewer = BibPreview,
					actions = {
						["default"] = function(selected)
							if not selected or #selected == 0 then
								return
							end

							local citekey = selected[1]:match("^(%S+)")
							if not citekey or citekey == "" then
								vim.notify("No entries associated with the selected reference", vim.log.levels.WARN)
								return ""
							end

							local entry = entries[citekey]
							if not entry then
								vim.notify("No entries associated with key: " .. citekey, vim.log.levels.WARN)
								return ""
							end

							local ref_text, link_text, title = citations.create_md_link_from_reference(entry)
							if not link_text or link_text == "" then
								vim.notify("No link for the selected entry", vim.log.levels.ERROR)
							end

							-- Copy the title to the system clipboard.
							vim.fn.setreg("+", title)

							-- Insert at cursor
							vim.api.nvim_put({ ref_text }, "c", true, true)
							-- Insert at EOF
							local n_lines = vim.api.nvim_buf_line_count(0)

							-- We need to set strict_indexing to `false` if we want to create a new line.
							vim.api.nvim_buf_set_lines(0, n_lines, n_lines + 1, false, { "", link_text })

							-- local last_nonblank = vim.fn.prevnonblank(n_lines)
							--
							-- if last_nonblank < n_lines then
							-- end
						end,
					},
					fzf_opts = {
						["--delimiter"] = "│",
						["--with-nth"] = "3", -- display only the title
					},
				})
			end,
			desc = "Insert BibTeX citation",
		},
		{
			"<leader>fn",
			function()
				local notes_dir = os.getenv("KNOWLEDGE_BASE")
				if not notes_dir or notes_dir == "" then
					return vim.notify("$KNOWLEDGE_BASE environment variable is not set")
				end

				require("fzf-lua").files({
					prompt = require("stepit.utils.icons").symbols.lens .. "    ",
					previewer = "builtin",
					cwd = notes_dir,
					find_opts = [[-type f \! -path '*/.*' \! -path '*/Deprecated/*']],
					rg_opts = [[--color=never --files -g "!.*" -g "!Deprecated"]],
					fd_opts = [[--color=never --type f --type l --exclude '.*' --exclude Deprecated]],
					-- With these opts we can grep only the file name.
					fzf_opts = {
						["--delimiter"] = "/",
						["--with-nth"] = "-1",
					},
					winopts = {
						fullscreen = false,
						preview = {
							hidden = true,
						},
					},
				})
			end,
			desc = "[F]ind [N]otes",
		},
		{
			"<leader>fk",
			function()
				require("fzf-lua").keymaps({})
			end,
			desc = "[F]ind [K]eymaps",
		},
		{ "<leader>fs", "<cmd>FzfLua live_grep<cr>", desc = "[F]ind [G]rep" },
		{ "<leader>fob", "<cmd>FzfLua buffers<cr>", desc = "[F]ind [B]uffers" },
		{ "<leader>fgb", "<cmd>FzfLua git_branches<cr>", desc = "[F]ind [G]it [B]ranches" },
		{ "<leader>fdd", "<cmd>FzfLua diagnostics_document<cr>", desc = "[F]ind [D]iagnostics [D]ocument" },
		{
			"<leader>fdw",
			function()
				require("fzf-lua").diagnostics_workspace({
					fzf_opts = {
						["--pointer"] = "┃",
					},
				})
			end,
			desc = "[F]ind [D]iagnostics [W]orkspace",
		},
		{ "<leader>fch", "<cmd>FzfLua highlights<cr>", desc = "[F]ind [C]olor [H]ighlights" },
	},
	opts = function()
		require("fzf-lua").register_ui_select()

		return {
			keymap = {
				fzf = {
					["ctrl-a"] = "toggle-all",
				},
			},
			previewers = {
				builtin = {
					syntax_limit_b = 1024 * 100, -- 100KB
				},
			},
		}
	end,
}
