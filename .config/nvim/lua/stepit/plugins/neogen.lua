return {
	"danymat/neogen",
	config = function()
		require("neogen").setup({
			enabled = true,
			languages = {
				python = {
					template = {
						annotation_convention = "numpydoc", -- for a full list of annotation_conventions, see supported-languages below,
					},
				},
			},
		})
	end,
}
