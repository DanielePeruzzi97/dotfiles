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
    lazygit = { enabled = true },
    picker = {
      enabled = true,
      layout = {
        preset = "sidebar",
      },
      -- win = {
      --   input = {
      --     ["<M-w>"] = { "cycle_win", mode = { "i", "n" } },
      --   },
      --   list = {
      --     ["<M-w>"] = { "cycle_win", mode = { "n" } },
      --   },
      --   preview = {
      --     ["<M-w>"] = { "cycle_win", mode = { "n" } },
      --   },
      -- },
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
    { "<leader>sb", function() Snacks.picker.git_branches() end, desc = "Branches" },
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
    { "<leader>lg", function() Snacks.lazygit.open() end, desc = "Lazygit"},
    { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
    { "<C-t>",      function() Snacks.terminal.open() end, desc = "Toggle Terminal" },
    { "<leader>sp", function() Snacks.picker.projects() end, desc = "Projects" },
    { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
    {"<leader>man", function() Snacks.picker.man() end, desc = "Man Pages"},
    --  add for man, current file dir, projects, better lsp, history
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
    {
      "<leader>aws",
      function()
        local find_aws_profiles = function(opts, ctx)
          local profiles = {}

          -- Get all profiles from AWS config and credentials
          local config_file = vim.fn.expand("~/.aws/config")
          local credentials_file = vim.fn.expand("~/.aws/credentials")

          -- Read and extract profile names from config
          local function read_profiles(file)
            if vim.fn.filereadable(file) == 1 then
              local content = vim.fn.readfile(file)
              for _, line in ipairs(content) do
                if line:match("%[.*%]") then
                  local profile = line:match("%[([^%]]+)%]")
                  if profile then
                    -- Get the sso-session if available (optional)
                    local sso_session = vim.fn.system("aws configure get sso-session --profile " .. profile)
                    local display_text = profile .. (sso_session ~= "" and " (SSO: " .. sso_session:match("%S+") .. ")" or "")

                    -- Insert profile into the profiles list with formatted text
                    table.insert(profiles, { text = display_text, profile = profile, sso_session = sso_session })
                  end
                end
              end
            end
          end

          -- Parse both config and credentials files
          read_profiles(config_file)
          read_profiles(credentials_file)

          return profiles
        end

        -- Preview Profile: Format properly
        local preview_profile = function(item)
          -- Extract profile and sso-session if available
          local profile = item.profile
          local sso_session = item.sso_session

          -- Format the preview text
          local preview_text = "Profile: " .. profile
          if sso_session ~= "" then
            preview_text = preview_text .. "\nSSO Session: " .. sso_session:match("%S+")
          end
          return preview_text
        end

        local change_profile = function(picker)
          picker:close()
          local item = picker:current()
          if not item then
            return
          end
          local profile = item.profile -- Access the profile field
          -- Set AWS_PROFILE environment variable
          vim.fn.setenv("AWS_PROFILE", profile)
          -- Optionally: Print to let user know the profile is set
          vim.notify("Switched to AWS profile: " .. profile, vim.log.levels.INFO)
        end

        Snacks.picker.pick({
          source = "AWS Profiles",
          finder = find_aws_profiles,
          format = "text",
          confirm = change_profile,
          preview = preview_profile,  -- Preview with profile info
          layout = {
            preset = "select",
            preview = { enabled = true, width = 40, height = 10 }, -- Show preview with profile details
          },
        })
      end,
      desc = "Select AWS profile and set AWS_PROFILE",
    },
  },

  config = function(_, opts)
    require("snacks").setup(opts)

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
  end,
}
