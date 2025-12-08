-- Ansible files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = {
    "*ansible*/*.yml",
    "*/roles/*/tasks/*.yml",
    "*/roles/*/handlers/*.yml",
    "*/playbooks/*.yml",
    "*/inventory/*.yml",
    "*ansible*.yml",
    "*ansible*/*.yaml",
    "*/roles/*/tasks/*.yaml",
    "*/roles/*/handlers/*.yaml",
    "*/playbooks/*.yaml",
    "*/inventory/*.yaml",
    "*ansible*.yaml",
  },
  callback = function()
    vim.bo.filetype = "yaml.ansible"
  end,
})

-- Terraform files
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.tf" },
  callback = function()
    vim.bo.filetype = "terraform"
  end,
})

-- Dockerfile variants
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "Dockerfile*" },
  callback = function()
    vim.bo.filetype = "dockerfile"
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
