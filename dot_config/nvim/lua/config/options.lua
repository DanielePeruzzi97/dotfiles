local opt = vim.opt

-- Clipboard integration
opt.clipboard = "unnamedplus"

-- UI Settings
opt.termguicolors = true
opt.mouse = "a"
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.showmode = false

-- Indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.smartindent = true
opt.breakindent = true

-- Scrolling
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Search
opt.incsearch = true
opt.hlsearch = false
opt.ignorecase = true
opt.smartcase = true

-- Editing
opt.undofile = true
opt.confirm = false
opt.inccommand = "split"

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }
