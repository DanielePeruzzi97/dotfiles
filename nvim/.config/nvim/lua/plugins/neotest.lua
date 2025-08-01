return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "weilbith/neotest-gradle",
  },
  config = function()
    require("neotest").setup({
      adapters = {
        require("neotest-gradle"),
      },
    })
  end,
}
