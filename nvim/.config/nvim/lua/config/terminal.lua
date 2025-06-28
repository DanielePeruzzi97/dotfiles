local opt_local = vim.opt_local

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
