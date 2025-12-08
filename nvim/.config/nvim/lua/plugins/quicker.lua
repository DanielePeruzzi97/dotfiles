return {
  "stevearc/quicker.nvim",
  ft = "qf",
  opts = {},
  config = function()
    local quicker = require("quicker")

    vim.keymap.set("n", "<leader>q", function()
      quicker.toggle()
    end, { desc = "[Q]uickfix toggle" })

    -- vim.keymap.set("n", "<leader>l", function()
    --   quicker.toggle({ loclist = true })
    -- end, { desc = "Toggle loclist" })

    quicker.setup({
      keys = {
        {
          ">",
          function()
            require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
          end,
          desc = "Expand quickfix context",
        },
        {
          "<",
          function()
            require("quicker").collapse()
          end,
          desc = "Collapse quickfix context",
        },
      },
    })
  end,
}
