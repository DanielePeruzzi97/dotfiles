local opt = vim.opt
local o = vim.o

opt.clipboard = "unnamedplus"
o.termguicolors = true -- terminal support colors
opt.mouse = "a" -- allow the mouse to be used in Nvim

opt.tabstop = 4 -- number of visual spaces per TAB
opt.shiftwidth = 4 -- insert 2 spaces on a tab
opt.expandtab = true -- tabs are spaces, mainly because of python
opt.scrolloff = 8
opt.smartindent = true

opt.number = true -- show absolute number
opt.relativenumber = true -- add numbers to each line on the left side
opt.splitbelow = true -- open new vertical split bottom
opt.splitright = true -- open new horizontal splits right
opt.showmode = false -- we are experienced, wo don't need the "-- INSERT --" mode hint

opt.incsearch = true -- search as characters are entered
opt.hlsearch = false -- do not highlight matches
opt.ignorecase = true -- ignore case in searches by default
opt.smartcase = true -- but make it case sensitive if an uppercase is entered

opt.undofile = true
opt.breakindent = true
opt.signcolumn = "yes"

-- opt.list = false
-- opt.listchars = {
--   tab = "» ",
--   trail = "·",
--   nbsp = "␣",
-- }

opt.inccommand = "split"
opt.cursorline = true
opt.confirm = false

opt.completeopt = { "menu", "menuone", "noselect" }
