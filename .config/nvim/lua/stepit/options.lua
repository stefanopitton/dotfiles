local lines = require("stepit.utils.icons").lines
local chevrons = require("stepit.utils.icons").chevrons

local opt = vim.opt

-- General

-- Sync Mac and Neovim clipboard.
opt.clipboard = "unnamedplus"

opt.completeopt = "menu,menuone,preview,noinsert,noselect"
-- Ignore DS_Store from patterns.
vim.opt.wildignore:append({ ".DS_Store" })
-- Max number of completion elements to display.
vim.o.pumheight = 15

opt.undofile = true
opt.swapfile = false

-- Enable mouse.
opt.mouse = "a"

opt.conceallevel = 0

opt.updatetime = 250
opt.timeoutlen = 250

-- UI
opt.termguicolors = true
opt.cursorline = true
opt.signcolumn = "yes"
opt.colorcolumn = "100"

-- Use rounded borders for floating windows.
vim.o.winborder = "rounded"

-- Scrolling
opt.scrolloff = 15
opt.sidescrolloff = 10
-- Numbers
opt.number = true
opt.relativenumber = true

-- Windows
opt.splitright = true
opt.splitbelow = true

-- Search

-- Case insensitive searching unless /C or the search has capitals.
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

-- Git diff config
vim.opt.diffopt:append({
	"internal", -- Use internal diff
	"algorithm:patience", -- Better diff algorithm
	"indent-heuristic", -- Better indent handling
	"linematch:60", -- Detect moved lines
})

vim.opt.diffopt:append("vertical")

-- Spelling
opt.spelllang = { "en" }
opt.spell = false

-- Folding
opt.foldcolumn = "0"
opt.foldenable = true
opt.foldmethod = "indent"
opt.foldtext = "" -- Using custom virtual text display (see utils/fold.lua)
opt.foldlevelstart = 99 -- no fold initially

opt.wrap = false

-- Indentation
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4

opt.smartindent = true

opt.laststatus = 2

-- Visual
opt.showmatch = true
opt.virtualedit = "block"
opt.list = true
opt.listchars = {
	space = " ",
	trail = "⋅",
	leadmultispace = "  ",
	tab = lines.vertical.left .. " ",
}
opt.fillchars = {
	foldclose = chevrons.right,
	foldopen = chevrons.down,
	foldsep = " ",
	diff = "╱",
}
opt.inccommand = "split"

-- Add blinking to cursor in different modes.
opt.guicursor = "n-v-c:block-blinkwait700-blinkon400-blinkoff250,"
	.. "i-ci-ve:ver25-blinkwait700-blinkon400-blinkoff250,"
	.. "r-cr:hor20-blinkwait700-blinkon400-blinkoff250"
