return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")
      configs.setup({
        auto_install = false,
        indent = { enable = true },
        autopairs = { enable = true },
        highlight = { enable = true },
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
        },
      })
    end,
  },
}
