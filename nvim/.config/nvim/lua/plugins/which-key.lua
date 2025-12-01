return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 300,
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
      mappings = true,
      keys = {
        Up = "↑ ",
        Down = "↓ ",
        Left = "← ",
        Right = "→ ",
        C = "C-",
        M = "A-",
        S = "S-",
        CR = "⏎ ",
        Esc = "⎋ ",
        Space = "␣ ",
        Tab = "⇥ ",
      },
    },
    win = {
      border = "rounded",
      padding = { 1, 2 },
    },
    spec = {
      -- Leader key groups
      { "<leader>b", group = "buffers" },
      { "<leader>d", group = "diff/diagnostics" },
      { "<leader>dir", group = "directory" },
      { "<leader>f", group = "file" },
      { "<leader>g", group = "git" },
      { "<leader>h", group = "git hunks" },
      { "<leader>l", group = "lsp" },
      { "<leader>n", group = "neotest" },
      { "<leader>q", group = "quickfix" },
      { "<leader>s", group = "search/snacks" },
      { "<leader>t", group = "toggle" },
      { "<leader>w", group = "window" },
      
      -- Visual mode groups
      { "<leader>g", group = "git", mode = "v" },
      { "<leader>h", group = "git hunks", mode = "v" },
      
      -- g-prefix groups (builtin Neovim)
      { "g", group = "goto" },
      { "gr", group = "lsp" },
      { "ga", group = "lsp calls" },
      
      -- Brackets navigation
      { "[", group = "prev" },
      { "]", group = "next" },
      
      -- Harpoon numbers
      { "<leader>1", desc = "Harpoon file 1" },
      { "<leader>2", desc = "Harpoon file 2" },
      { "<leader>3", desc = "Harpoon file 3" },
      { "<leader>4", desc = "Harpoon file 4" },
      { "<leader>5", desc = "Harpoon file 5" },
    },
  },
}
