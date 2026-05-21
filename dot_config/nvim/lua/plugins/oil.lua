return {
  {
    "stevearc/oil.nvim",
    opts = {},
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    config = function()
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Oil parent directory" })
      vim.keymap.set("n", "<space>-", require("oil").toggle_float, { desc = "Oil toggle float" })

      -- Winbar function to show current directory
      function _G.get_oil_winbar()
        local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
        local dir = require("oil").get_current_dir(bufnr)
        if dir then
          return vim.fn.fnamemodify(dir, ":~")
        else
          return vim.api.nvim_buf_get_name(0)
        end
      end

      require("oil").setup({
        columns = {
          "icon",
          "permissions",
        },
        win_options = {
          winbar = "%!v:lua.get_oil_winbar()",
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
          rcd = {
            callback = function()
              local dir = require("oil").get_current_dir()
              Snacks.picker.files({ cwd = dir })
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
