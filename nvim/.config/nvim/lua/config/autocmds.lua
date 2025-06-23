return {
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = {
      "*/roles/*/tasks/*.yml",
      "*/roles/*/handlers/*.yml",
      "*/playbooks/*.yml",
      "*/inventory/*.yml",
      "*ansible*.yml",
    },
    callback = function()
      vim.bo.filetype = "yaml.ansible"
    end,
  }),

  vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
      vim.highlight.on_yank()
    end,
  }),
}
