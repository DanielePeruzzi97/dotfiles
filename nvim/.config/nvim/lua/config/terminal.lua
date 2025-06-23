local opt_local = vim.opt_local
local set = vim.keymap.set

-- Set local settings for terminal buffers
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("custom-term-open", {}),
  callback = function()
    opt_local.number = false
    opt_local.relativenumber = false
    opt_local.scrolloff = 0

    vim.bo.filetype = "terminal"
  end,
})

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
