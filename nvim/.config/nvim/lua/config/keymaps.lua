local set = vim.keymap.set

-- Window resizing
set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
set("n", "<C-Right>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
set("n", "<C-Left>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Window splits
set("n", "<leader>wh", "<cmd>split<cr>", { desc = "Horizontal split" })
set("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Vertical split" })
set("n", "<leader>wc", "<cmd>close<cr>", { desc = "Close window" })

-- Navigation with centering
set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })
set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Clipboard operations
set("x", "<leader>p", [["_dP]], { desc = "Paste without yank" })
set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
set("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })
set("n", "<C-v>", '"+p', { desc = "Paste from clipboard" })
set("i", "<C-v>", "<C-r>+", { desc = "Paste from clipboard" })
set("c", "<C-v>", "<C-r>+", { desc = "Paste from clipboard" })

-- Delete without yank
set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete to black hole" })

-- Substitution
set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]], { desc = "Substitute word under cursor" })

-- Visual mode indenting
set("v", "<", "<gv", { desc = "Indent left and reselect" })
set("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Move visual selection
set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Clear search highlight
set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
set("i", "jj", "<Esc>", { desc = "Exit insert mode" })

set("n", "<leader>nr", "<cmd>lua require('neotest').run.run()<cr>", { desc = "Run nearest test" })

-- tmux-sessionizer bindings - consistent with tmux and zsh
-- Main sessionizer fuzzy finder
set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Tmux sessionizer" })

-- Session commands (self-explanatory keys)
set("n", "<M-h>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>", { desc = "Htop" })
set("n", "<M-g>", "<cmd>silent !tmux neww tmux-sessionizer -s 1<CR>", { desc = "Lazygit" })
set("n", "<M-o>", "<cmd>silent !tmux neww tmux-sessionizer -s 2<CR>", { desc = "Opencode" })

-- Easily hit escape in terminal mode.
-- set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Open a terminal at the bottom of the screen with a fixed height.
-- set("n", ",t", function()
--   vim.cmd.new()
--   vim.cmd.wincmd("J")
--   vim.api.nvim_win_set_height(0, 12)
--   vim.wo.winfixheight = true
--   vim.cmd.term()
-- end)

