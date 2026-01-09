local set = vim.keymap.set

-- Window resizing (Alt+hjkl - matches tmux)
set("n", "<M-h>", ":vertical resize +2<CR>", { desc = "Increase window width" })
set("n", "<M-l>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
set("n", "<M-k>", ":resize +2<CR>", { desc = "Increase window height" })
set("n", "<M-j>", ":resize -2<CR>", { desc = "Decrease window height" })

-- Window splits
set("n", "<leader>wh", "<cmd>split<cr>", { desc = "[W]indow Split [H]orizontal" })
set("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "[W]indow Split [V]ertical" })
set("n", "<leader>wc", "<cmd>close<cr>", { desc = "[W]indow [C]lose" })

-- Navigation with centering
set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down (centered)" })
set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up (centered)" })
set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })

-- Clipboard
set("x", "<leader>p", [["_dP]], { desc = "Paste without yank" })
set({ "n", "v" }, "<leader>y", [["+y]], { desc = "[Y]ank to clipboard" })
set("n", "<leader>Y", [["+Y]], { desc = "[Y]ank line to clipboard" })
set("n", "<C-v>", '"+p', { desc = "Paste from clipboard" })
set("i", "<C-v>", "<C-r>+", { desc = "Paste from clipboard" })
set("c", "<C-v>", "<C-r>+", { desc = "Paste from clipboard" })

-- Delete without yank
set({ "n", "v" }, "<leader>d", '"_d', { desc = "[D]elete to black hole" })

-- Substitution
set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]], { desc = "[S]ubstitute word" })

-- Visual mode indenting
set("v", "<", "<gv", { desc = "Indent left" })
set("v", ">", ">gv", { desc = "Indent right" })

-- Move visual selection
set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Clear search highlight
set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
set("i", "jj", "<Esc>", { desc = "Exit insert mode" })

-- Main sessionizer fuzzy finder
set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Tmux sessionizer" })

-- Session commands (Alt+1/2/3)
set("n", "<M-1>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>", { desc = "Tmux Htop" })
set("n", "<M-2>", "<cmd>silent !tmux neww tmux-sessionizer -s 1<CR>", { desc = "Tmux Lazygit" })
set("n", "<M-3>", "<cmd>silent !tmux neww tmux-sessionizer -s 2<CR>", { desc = "Tmux Opencode" })

-- Add empty lines without entering insert mode (unimpaired style)
set("n", "]<Space>", "<cmd>put _<CR>", { desc = "Add empty line below" })
set("n", "[<Space>", "<cmd>put! _<CR>", { desc = "Add empty line above" })
