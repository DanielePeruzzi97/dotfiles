return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Linter configuration by filetype
    lint.linters_by_ft = {
      -- python = { "pylint" },
      bash = { "shellcheck" },
      terraform = { "tflint" },
      markdown = { "markdownlint" },
      json = { "jsonlint" },
      dockerfile = { "hadolint" },
      yaml = { "yamllint" },
    }

    -- Auto-lint on specific events
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    -- Manual lint trigger
    vim.keymap.set("n", "<leader>l", function()
      lint.try_lint()
    end, { desc = "[L]int current file" })

    -- Linter customization
    lint.linters.markdownlint.args = {
      "--disable",
      "MD013", -- Disable line length rule
      "--",
    }

    lint.linters.yamllint.args = {
      "-d",
      "{extends: default, rules: {line-length: {max: 120}}}",
    }
  end,
}
