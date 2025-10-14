local set = vim.keymap.set
local opts = {
  noremap = true,
  silent = true,
}

set("n", "<leader>X", "<cmd>source %<CR>", { desc = "Execute the current file" })

-- set("n", "<A-h>", "<C-w>h", opts)
-- set("n", "<A-j>", "<C-w>j", opts)
-- set("n", "<A-k>", "<C-w>k", opts)
-- set("n", "<A-l>", "<C-w>l", opts)

set("n", "<C-Down>", ":resize -2<CR>", opts)
set("n", "<C-Up>", ":resize +2<CR>", opts)
set("n", "<C-Right>", ":vertical resize -2<CR>", opts)
set("n", "<C-Left>", ":vertical resize +2<CR>", opts)

set("n", "<leader>wh", "<cmd>split<cr>", { desc = "Horizontal split" })
set("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Vertical split" })
set("n", "<leader>wc", "<cmd>close<cr>", { desc = "Close" })

set("n", "<C-d>", "<C-d>zz")
set("n", "<C-u>", "<C-u>zz")
set("n", "n", "nzzzv")
set("n", "N", "Nzzzv")

-- Substitute the selected text without override the registry
set("x", "<leader>p", [["_dP]])

-- Copy in the system register
set({ "n", "v" }, "<leader>y", [["+y]])
set("n", "<leader>Y", [["+Y]])

set("n", "<C-v>", '"+p')
set("i", "<C-v>", "<C-r>+")
set("c", "<C-v>", "<C-r>+")

-- Delete without copy
set({ "n", "v" }, "<leader>d", '"_d')

-- Substitue globally the word under the cursor
set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

set("v", "<", "<gv", opts)
set("v", ">", ">gv", opts)

-- Move up and down the selection
set("v", "J", ":m '>+1<CR>gv=gv")
set("v", "K", ":m '<-2<CR>gv=gv")

set("n", "<Esc>", "<cmd>nohlsearch<CR>")
set("i", "jj", "<Esc>")

set("n", "<leader>nr", "<cmd>lua require('neotest').run.run()<cr>", { desc = "Run nearest test" })

-- Easily hit escape in terminal mode.
set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Open a terminal at the bottom of the screen with a fixed height.
set("n", ",t", function()
  vim.cmd.new()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, 12)
  vim.wo.winfixheight = true
  vim.cmd.term()
end)
