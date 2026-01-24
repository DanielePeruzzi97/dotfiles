return {
  -- Enhanced text objects
  -- Examples:
  --   va)  - [V]isually select [A]round [)]paren
  --   yinq - [Y]ank [I]nside [N]ext [Q]uote
  --   ci'  - [C]hange [I]nside [']quote
  {
    "nvim-mini/mini.ai",
    config = function()
      require("mini.ai").setup({ n_lines = 500 })
    end,
  },

  -- Add/delete/replace surroundings (brackets, quotes, etc.)
  -- Examples:
  --   saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
  --   sd'   - [S]urround [D]elete [']quotes
  --   sr)'  - [S]urround [R]eplace [)] [']
  {
    "nvim-mini/mini.surround",
    config = function()
      require("mini.surround").setup()
    end,
  },

  -- Auto-close pairs
  {
    "nvim-mini/mini.pairs",
    config = function()
      require("mini.pairs").setup()
    end,
  },

  -- Split/join arguments (gS to toggle)
  {
    "nvim-mini/mini.splitjoin",
    config = function()
      require("mini.splitjoin").setup()
    end,
  },
}
