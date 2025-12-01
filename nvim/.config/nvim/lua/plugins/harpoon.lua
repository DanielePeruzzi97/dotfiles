return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    -- Toggle menu
    vim.keymap.set("n", "<C-e>", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "Harpoon menu" })

    -- Add/prepend files
    vim.keymap.set("n", "<leader>a", function()
      harpoon:list():add()
    end, { desc = "[A]dd file to Harpoon" })

    vim.keymap.set("n", "<leader>A", function()
      harpoon:list():prepend()
    end, { desc = "[A]dd file to Harpoon (prepend)" })

    -- Replace at position
    vim.keymap.set("n", "<C-1>", function()
      harpoon:list():replace_at(1)
    end, { desc = "Harpoon replace 1" })

    vim.keymap.set("n", "<C-2>", function()
      harpoon:list():replace_at(2)
    end, { desc = "Harpoon replace 2" })

    vim.keymap.set("n", "<C-3>", function()
      harpoon:list():replace_at(3)
    end, { desc = "Harpoon replace 3" })

    vim.keymap.set("n", "<C-4>", function()
      harpoon:list():replace_at(4)
    end, { desc = "Harpoon replace 4" })

    -- Select files by number
    for _, idx in ipairs({ 1, 2, 3, 4, 5 }) do
      vim.keymap.set("n", string.format("<space>%d", idx), function()
        harpoon:list():select(idx)
      end, { desc = string.format("Harpoon file %d", idx) })
    end

    -- Navigation
    vim.keymap.set("n", "<leader><C-p>", function()
      harpoon:list():prev()
    end, { desc = "Harpoon [P]revious" })

    vim.keymap.set("n", "<leader><C-n>", function()
      harpoon:list():next()
    end, { desc = "Harpoon [N]ext" })
  end,
}
