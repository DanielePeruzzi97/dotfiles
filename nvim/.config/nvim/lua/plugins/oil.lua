return {
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,

    config = function()
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
      vim.keymap.set("n", "<space>-", require("oil").toggle_float)
      require("oil").setup({
        columns = {
          "icon",
          "permissions",
        },
        default_file_explorer = true,
        skip_confirm_for_simple_edits = true,
        prompt_save_on_select_new_entry = false,
        watch_for_changes = true,
        natural_order = true,
        constrain_cursor = "editable",
        is_always_hidden = function(name, _)
          return name == ".." or name == ".git"
        end,
        keymaps = {
          ["<C-j>"] = false,
          ["<C-k>"] = false,
          ["<C-l>"] = false,
          ["<C-p>"] = "actions.preview",
          ["<C-c>"] = { "actions.close", mode = "n" },
          ["<C-v>"] = { "actions.select", opts = { vertical = true } },
          ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
          -- create a new mapping, rcd, to search and Replace in the Current Directory
          rcd = {
            callback = function()
              -- get the current directory
              local prefills = { paths = require("oil").get_current_dir() }

              local grug_far = require("grug-far")
              -- instance check
              if not grug_far.has_instance("explorer") then
                grug_far.open({
                  instanceName = "explorer",
                  prefills = prefills,
                  staticTitle = "Find and Replace from Explorer",
                })
              else
                grug_far.get_instance("explorer"):open()
                -- updating the prefills without clearing the search and other fields
                grug_far.get_instance("explorer"):update_input_values(prefills, false)
              end
            end,
            desc = "oil: Search in directory",
          },
        },
        view_options = {
          show_hidden = true,
          case_insensitive = true,
        },
      })
    end,
  },
  {
    "benomahony/oil-git.nvim",
    dependencies = { "stevearc/oil.nvim" },
  },
}
