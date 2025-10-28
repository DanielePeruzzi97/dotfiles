return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    keys = {
      { "\\", ":Neotree reveal<CR>", desc = "NeoTree reveal", silent = true },
    },
    opts = {
      enable_git_status = true,
      filesystem = {
        hijack_netrw_behavior = "disabled",
        window = {
          mappings = {
            ["\\"] = "close_window",
          },
        },
      },
    },
  },
}
