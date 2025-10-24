return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",

      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
    { "nvim-telescope/telescope-ui-select.nvim" },
    { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
  },

  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local utils = require("telescope.utils")
    local builtin = require("telescope.builtin")
    local map = vim.keymap.set

    local diff_with_current = function(prompt_bufnr)
      local selection = action_state.get_selected_entry()
      if not selection or selection.path == nil then
        return
      end

      local selected_file = selection.path

      actions.close(prompt_bufnr)
      local current_file = vim.fn.expand("%:t")

      vim.cmd.vsplit(selected_file)
      vim.cmd.diffthis() -- Enable diff on the selected file (right window)
      vim.cmd.wincmd("p") -- Switch back to the original file (left window)
      vim.cmd.diffthis() -- Enable diff on the original file

      vim.cmd.wincmd("l") -- Go to the right window
      vim.cmd("normal! [c")

      print('Diffing "' .. current_file .. '" with "' .. selection.value .. '"')
    end

    telescope.setup({
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown(),
        },
      },
      defaults = {
        mappings = {
          i = { ["<C-d>"] = diff_with_current },
          n = { ["<C-d>"] = diff_with_current },
        },
      },
    })

    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "ui-select")

    map("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
    map("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
    map("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
    map("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
    map("n", "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
    map("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
    map("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
    map("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
    map("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    map("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })
    map("n", "<leader>sn", function()
      builtin.find_files({ cwd = vim.fn.stdpath("config") })
    end, { desc = "[S]earch [N]eovim files" })
    map("n", "<leader>s/", function()
      builtin.live_grep({
        grep_open_files = true,
        prompt_title = "Live Grep in Open Files",
      })
    end, { desc = "[S]earch [/] in Open Files" })

    local setup_diff_keymaps = function()
      if vim.wo.diff then
        map("n", "<Leader>n", "]c", { desc = "Go to Next Diff Hunk", buffer = true })
        map("n", "<Leader>p", "[c", { desc = "Go to Previous Diff Hunk", buffer = true })
        map("n", "<Leader>g", ":diffget<CR>", { desc = "Get Hunk from Other Buffer", buffer = true }) -- Get/Pull
        map("n", "<Leader>P", ":diffput<CR>", { desc = "Put Hunk to Other Buffer", buffer = true }) -- Put/Push
        map("n", "<Leader>do", ":diffoff<CR>", { desc = "Turn Off Diff Mode" })
      end
    end

    vim.api.nvim_create_autocmd({ "WinEnter", "BufReadPost" }, {
      pattern = "*",
      callback = setup_diff_keymaps,
    })

    map("n", "<Leader>dd", ":windo diffthis<CR>", { desc = "Enable Diff on All Splits" })
  end,
}
