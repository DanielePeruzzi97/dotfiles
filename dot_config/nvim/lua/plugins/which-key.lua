return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 200,
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    wk.add({
      { "<leader>a", group = "Add" },
      { "<leader>b", group = "Buffer" },
      { "<leader>d", group = "Delete/Diff" },
      { "<leader>f", group = "Format/File" },
      { "<leader>g", group = "Git" },
      { "<leader>j", group = "Jump" },
      { "<leader>l", group = "LSP/Lint" },
      { "<leader>o", group = "Opencode" },
      { "<leader>s", group = "Search/Substitute" },
      { "<leader>w", group = "Window" },
    })
  end,
}
