return {
  {
    "nvim-mini/mini.ai",
    config = function()
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require("mini.ai").setup({ n_lines = 500 })
    end,
  },
  {
    "nvim-mini/mini.surround",
    config = function()
      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require("mini.surround").setup()
    end,
  },
  {
    "nvim-mini/mini.pairs",
    config = function()
      require("mini.pairs").setup()
    end,
  },
  -- {
  --   "nvim-mini/mini.statusline",
  --   config = function()
  --     local statusline = require("mini.statusline")
  --     statusline.setup({ use_icons = vim.g.have_nerd_font })
  --
  --     ---@diagnostic disable-next-line: duplicate-set-field
  --     statusline.section_location = function()
  --       return "%2l:%-2v"
  --     end
  --   end,
  -- },
  {
    "nvim-mini/mini.splitjoin",
    config = function()
      -- - gS to splijoin
      require("mini.splitjoin").setup()
    end,
  },
}
