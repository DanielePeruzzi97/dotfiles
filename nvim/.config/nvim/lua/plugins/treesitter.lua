return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")
    configs.setup({
      auto_install = false,
      sync_install = false,
      modules = {},
      ignore_install = {},
      ensure_installed = {
        "vimdoc",
        "javascript",
        "lua",
        "bash",
        "go",
        "query",
        "markdown",
        "markdown_inline",
        "python",
        "dockerfile",
        "groovy",
        "html",
        "java",
        "jinja",
        "jinja_inline",
        "json",
        "terraform",
        "hcl",
      },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      autopairs = {
        enable = true,
      },
    })
  end,
}
