return {
  "romgrk/barbar.nvim",
  dependencies = {
    "lewis6991/gitsigns.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  init = function()
    vim.g.barbar_auto_setup = false
  end,
  opts = {
    auto_hide = 1,
    clickable = true,
    animation = false,
    icons = {
      gitsigns = {
        added = { enabled = true, icon = "+" },
        changed = { enabled = true, icon = "~" },
        deleted = { enabled = true, icon = "-" },
      },
    },
  },
  config = function(_, opts)
    require("barbar").setup(opts)

    local map = vim.keymap.set
    map("n", "<A-,>", "<Cmd>BufferPrevious<CR>", {
      noremap = true,
      silent = true,
      desc = "Previous buffer",
    })
    map("n", "<A-.>", "<Cmd>BufferNext<CR>", {
      noremap = true,
      silent = true,
      desc = "Next buffer",
    })
    map("n", "<A-c>", "<Cmd>BufferClose<CR>", {
      noremap = true,
      silent = true,
      desc = "Close buffer",
    })
    map("n", "<C-p>", "<Cmd>BufferPick<CR>", {
      noremap = true,
      silent = true,
      desc = "Pick buffer",
    })
  end,
}
