return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    dim = { enabled = true },
    dashboard = { enabled = false },
    indent = {
      enabled = true,
      indent = { only_scope = true },
      animate = { enabled = false },
    },
    image = { enabled = true },
    input = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 2000,
    },
    gitbrowse = { enabled = true },
    lazygit = { enabled = false }, -- Using tmux integration instead
    picker = {
      enabled = true,
      layout = {
        preset = "sidebar",
      },
      -- Global diff action for all pickers
      actions = {
        diff_with_current = function(picker)
          local item = picker:current()
          if not item then
            vim.notify("No item selected", vim.log.levels.WARN)
            return
          end

          -- Get the file path from the item
          local selected_file = item.file or item.filename or item.path
          if not selected_file then
            vim.notify("Selected item is not a file", vim.log.levels.WARN)
            return
          end

          -- Get absolute path
          selected_file = vim.fn.fnamemodify(selected_file, ":p")

          local current_file = vim.api.nvim_buf_get_name(0)
          local current_filename = vim.fn.fnamemodify(current_file, ":t")
          local selected_filename = vim.fn.fnamemodify(selected_file, ":t")

          -- Don't diff with itself
          if current_file == selected_file then
            vim.notify("Cannot diff a file with itself", vim.log.levels.WARN)
            return
          end

          picker:close()

          -- Open diff in vertical split
          vim.cmd.vsplit(selected_file)
          vim.cmd.diffthis() -- Enable diff on the selected file (right window)
          vim.cmd.wincmd("p") -- Switch back to the original file (left window)
          vim.cmd.diffthis() -- Enable diff on the original file

          -- Jump to first difference
          vim.cmd.wincmd("l") -- Go to the right window
          vim.cmd.normal({ "[c", bang = true }) -- Jump to first change

          vim.notify(string.format('Diffing "%s" with "%s"', current_filename, selected_filename), vim.log.levels.INFO)
        end,
      },
      win = {
        input = {
          keys = {
            ["<C-d>"] = { "diff_with_current", mode = { "n", "i" }, desc = "Diff with Current Buffer" },
          },
        },
        list = {
          keys = {
            ["<C-d>"] = { "diff_with_current", mode = { "n" }, desc = "Diff with Current Buffer" },
          },
        },
      },
    },
    explorer = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = false },
    words = { enabled = true },
    terminal = {
      enabled = true,
      stack = true,
      keys = {
        ["<esc>"] = "hide",
      },
    },
    zen = { enabled = false },
    styles = {
      notification = {
        wo = { wrap = true },
      },
    },
  },
  keys = {
    -- stylua: ignore start
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    { "<leader>gB", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
    { "<leader>go", mode = {"n", "v"}, function() Snacks.gitbrowse() end, desc = "Open git link" },
    { "<leader>gc", mode = {"n", "v"}, function() Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })end, desc = "Copy git link" },
    { "<leader>sgb", function() Snacks.picker.git_branches() end, desc = "Branches" },
    { "<leader>su", function() Snacks.picker.undo() end, desc = "Undo Tree" },
    { "<leader>fR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Strings" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Help" },
    { "<leader>sn", function() Snacks.picker.files({cwd = vim.fn.stdpath("config") }) end, desc = "[S]earch [N]eovim files" },
    { "<leader>sf", function() Snacks.picker.files({hidden = true}) end, desc = "[S]earch [F]iles" },
    { "<leader>sr", function() Snacks.picker.recent() end, desc = "Recent" },
    { "<leader>sb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>ls", function() Snacks.picker.lsp_symbols() end, desc = "Documents Symbols" },
    { "<leader>lS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace Symbols" },
    { "<leader>sz", function() Snacks.picker.zoxide() end, desc = "Zoxide" },
    { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
    { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
    { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
    { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
    { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
    { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },
    { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },
    { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
    { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>ld", function() Snacks.picker.lsp_definitions() end, desc = "Definition" },
    { "<leader>lr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
    { "<leader>lI", function() Snacks.picker.lsp_implementations() end, desc = "Implementation" },
    { "<leader>lt", function() Snacks.picker.lsp_type_definitions() end, desc = "Type Definition" },
    { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
    { "<C-t>",      function() Snacks.terminal.open() end, desc = "Toggle Terminal" },
    { "<leader>sp", function() Snacks.picker.projects({dev = {"~/.dotfiles/", "~/omnys/git/"}}) end, desc = "Projects" },
    { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
    {"<leader>man", function() Snacks.picker.man() end, desc = "Man Pages"},
    -- Diff keymaps
    { "<leader>dd", ":windo diffthis<CR>", desc = "Diff All Splits" },
    -- better lsp, history
    {
      "<leader>dir",
      function()
        local find_directory = function(opts, ctx)
          local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
          if vim.v.shell_error ~= 0 or not git_root or git_root == "" then
            git_root = vim.loop.cwd()
          end
          return require("snacks.picker.source.proc").proc({
            cmd = "fdfind",
            args = {
              "--type",
              "d",
              "--hidden",
              "--exclude", ".git",
              "--exclude", ".npm",
              "--exclude", "node_modules",
              ".",
              git_root,
            },
          }, ctx)
        end

        local change_directory = function(picker)
          picker:close()
          local item = picker:current()
          if not item then
            return
          end
          local dir = vim.fn.fnamemodify(item.text, ":p")
          vim.fn.chdir(dir)
          require("oil").open(dir)
          vim.notify("Changed directory to: " .. dir, vim.log.levels.INFO)
        end

        Snacks.picker.pick({
          source = "Directories",
          finder = find_directory,
          format = "text",
          confirm = change_directory,
          preview = "none",
          layout = {
            preset = "bottom",
            preview = { enabled = false },
          },
        })
      end,
      desc = "Find and change directory with Oil",
    },
  },

  config = function(_, opts)
    require("snacks").setup(opts)

    -- Terminal mode keymaps
    vim.api.nvim_create_autocmd("TermOpen", {
      callback = function(args)
        local bufnr = args.buf

        -- In terminal mode: <Esc> -> exit to normal mode
        vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", {
          buffer = bufnr,
          noremap = true,
          silent = true,
          desc = "Exit terminal mode",
        })
      end,
    })

    -- Diff mode keymaps
    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
      group = vim.api.nvim_create_augroup("DiffModeKeymaps", { clear = true }),
      callback = function()
        if vim.wo.diff then
          local opts_base = { buffer = true, silent = true }
          vim.keymap.set("n", "]c", "]c", vim.tbl_extend("force", opts_base, { desc = "Next Diff Hunk" }))
          vim.keymap.set("n", "[c", "[c", vim.tbl_extend("force", opts_base, { desc = "Previous Diff Hunk" }))
          vim.keymap.set(
            "n",
            "<leader>dg",
            ":diffget<CR>",
            vim.tbl_extend("force", opts_base, { desc = "Diff Get (Pull)" })
          )
          vim.keymap.set(
            "n",
            "<leader>dp",
            ":diffput<CR>",
            vim.tbl_extend("force", opts_base, { desc = "Diff Put (Push)" })
          )
          vim.keymap.set("n", "<leader>do", function()
            vim.cmd.diffoff()
            vim.notify("Diff mode disabled", vim.log.levels.INFO)
          end, vim.tbl_extend("force", opts_base, { desc = "Diff Off" }))
          vim.keymap.set("n", "<leader>du", function()
            vim.cmd.diffupdate()
            vim.notify("Diff updated", vim.log.levels.INFO)
          end, vim.tbl_extend("force", opts_base, { desc = "Diff Update" }))
        end
      end,
    })
  end,
}
