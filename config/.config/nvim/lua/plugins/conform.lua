return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = "",
      desc = "[F]ormat buffer",
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = {
      timeout_ms = 500,
      lsp_format = "fallback",
    },
    formatters_by_ft = {
      lua = { "stylua" },
      go = { "gofmt" },
      python = { "black" },
      javascript = { "prettierd", "prettier", stop_after_first = true },
      xml = { "xmlformatter" },
      -- yaml = { "yamlfmt" },
      -- ["yaml.ansible"] = { "yamlfmt" },
      bash = { "shfmt" },
      sh = { "shfmt" },
    },
  },
  config = function(_, opts)
    local conform = require("conform")
    conform.setup(opts)
    conform.formatters.shfmt = {
      prepend_args = { "-i", "2" }, -- 2 spaces instead of tab
    }
    conform.formatters.stylua = {
      prepend_args = { "--indent-type", "Spaces", "--indent-width", "2" },
    }
    -- conform.formatters.yamlfmt = {
    --   prepend_args = { "-formatter", "indent=2,include_document_start=true,retain_line_breaks_single=true" },
    -- }
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      callback = function(args)
        conform.format({ bufnr = args.buf })
      end,
    })
  end,
}
