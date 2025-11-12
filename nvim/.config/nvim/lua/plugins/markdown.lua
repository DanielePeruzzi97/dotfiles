return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you use the mini.nvim suite
  opts = {},
  config = function()
    require("render-markdown").setup({
      completions = {
        lsp = { enabled = true },
        blink = { enabled = true },
      },
    })
  end,
}
