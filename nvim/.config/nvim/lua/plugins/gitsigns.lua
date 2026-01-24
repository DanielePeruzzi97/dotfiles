return {
  "lewis6991/gitsigns.nvim",
  opts = {
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "‾" },
      changedelete = { text = "~" },
    },
  },
  config = function()
    require("gitsigns").setup({
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Only keep blame toggle and diff utilities
        map("n", "<leader>gb", function()
          gitsigns.toggle_current_line_blame()
        end, { desc = "[G]it Toggle [B]lame" })

        map("n", "<leader>gd", function()
          gitsigns.diffthis()
        end, { desc = "[G]it [D]iff" })

        map("n", "<leader>gD", function()
          gitsigns.diffthis("~")
        end, { desc = "[G]it [D]iff HEAD~" })
      end,
    })
  end,
}
