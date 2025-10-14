return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- "nvim-telescope/telescope.nvim",
  },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()
    -- local conf = require("telescope.config").values
    -- local function toggle_telescope(harpoon_files)
    --   local file_paths = {}
    --   for _, item in ipairs(harpoon_files.items) do
    --     table.insert(file_paths, item.value)
    --   end
    --
    --   require("telescope.pickers")
    --     .new({}, {
    --       prompt_title = "Harpoon",
    --       finder = require("telescope.finders").new_table({
    --         results = file_paths,
    --       }),
    --       previewer = conf.file_previewer({}),
    --       sorter = conf.generic_sorter({}),
    --     })
    --     :find()
    -- end
    --
    -- vim.keymap.set("n", "<C-e>", function()
    --   toggle_telescope(harpoon:list())
    -- end, { desc = "Open harpoon window" })

    vim.keymap.set("n", "<C-e>", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end)
    vim.keymap.set("n", "<leader>A", function()
      harpoon:list():prepend()()
    end)
    vim.keymap.set("n", "<leader>a", function()
      harpoon:list():add()
    end)
    vim.keymap.set("n", "<C-1>", function()
      harpoon:list():replace_at(1)
    end)
    vim.keymap.set("n", "<C-2>", function()
      harpoon:list():replace_at(2)
    end)
    vim.keymap.set("n", "<C-3>", function()
      harpoon:list():replace_at(3)
    end)
    vim.keymap.set("n", "<C-4>", function()
      harpoon:list():replace_at(4)
    end)

    -- Set <space>1..<space>5 be my shortcuts to moving to the files
    for _, idx in ipairs({ 1, 2, 3, 4, 5 }) do
      vim.keymap.set("n", string.format("<space>%d", idx), function()
        harpoon:list():select(idx)
      end)
    end

    -- Toggle previous & next buffers stored within Harpoon list
    vim.keymap.set("n", "<leader><C-p>", function()
      harpoon:list():prev()
    end)
    vim.keymap.set("n", "<leader><C-n>", function()
      harpoon:list():next()
    end)
  end,
}
