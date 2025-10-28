return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "williamboman/mason.nvim", opts = {} },
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    { "j-hui/fidget.nvim", opts = {} },
    "saghen/blink.cmp",
    "b0o/schemastore.nvim",
  },
  config = function()
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
      callback = function(event)
        local map = function(keys, func, desc, mode)
          mode = mode or "n"
          vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
        end

        map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
        map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
        map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
        map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
        map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
        map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
        map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")
        map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
        map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

        -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
        ---@param client vim.lsp.Client
        ---@param method vim.lsp.protocol.Method
        ---@param bufnr? integer some lsp support methods only in specific files
        ---@return boolean
        local function client_supports_method(client, method, bufnr)
          if vim.fn.has("nvim-0.11") == 1 then
            return client:supports_method(method, bufnr)
          else
            return client.supports_method(method, { bufnr = bufnr })
          end
        end

        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if
          client
          and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
        then
          local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd("LspDetach", {
            group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
            end,
          })
        end

        if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          map("<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
          end, "[T]oggle Inlay [H]ints")
        end
      end,
    })

    vim.diagnostic.config({
      severity_sort = true,
      float = { border = "rounded", source = "if_many" },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = "󰅚 ",
          [vim.diagnostic.severity.WARN] = "󰀪 ",
          [vim.diagnostic.severity.INFO] = "󰋽 ",
          [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
      } or {},
      virtual_text = {
        source = "if_many",
        spacing = 2,
        format = function(diagnostic)
          local diagnostic_message = {
            [vim.diagnostic.severity.ERROR] = diagnostic.message,
            [vim.diagnostic.severity.WARN] = diagnostic.message,
            [vim.diagnostic.severity.INFO] = diagnostic.message,
            [vim.diagnostic.severity.HINT] = diagnostic.message,
          }
          return diagnostic_message[diagnostic.severity]
        end,
      },
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    local blink_capabilities = require("blink.cmp").get_lsp_capabilities()
    capabilities = vim.tbl_deep_extend("force", capabilities, blink_capabilities)

    local servers = {
      gopls = {},
      pyright = {},
      jsonls = {
        settings = {
          validate = { enable = true },
          schemas = require("schemastore").json.schemas(),
        },
      },
      eslint = {},
      lua_ls = {
        settings = {
          format = {
            enable = false,
          },
          Lua = {
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      },
      hadolint = {},
      dockerls = {},
      groovyls = {
        filetypes = { "Jenkinsfile", "groovy" },
      },
      dotls = {},
      marksman = {},
      bashls = {},
      ansiblels = {},
      docker_compose_language_service = {},
      terraformls = {
        on_attach = function(client, bufnr)
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          for _, line in ipairs(lines) do
            if line:match("<<%s*['\"]?BUILD_SPEC['\"]?") then
              vim.notify(
                "terraform-ls disabled for files containing heredoc BUILD_SPEC: " .. vim.api.nvim_buf_get_name(bufnr),
                vim.log.levels.WARN
              )
              client.stop()
              return
            end
          end
        end,
        filetypes = { "terraform", "terraform-vars", "terraform-stack" },
      },
      yamlls = {
        filetypes = { "yaml", "yaml.ansible" },
        capabilities = {
          textDocument = {
            foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true,
            },
          },
        },
        settings = {
          redhat = { telemetry = { enabled = false } },
          yaml = {
            schemaStore = {
              enable = false,
              url = "",
            },
            format = { enabled = true },
            validate = true,
            completion = true,
            hover = true,
            schemas = {
              require("schemastore").yaml.schemas(),
            },
          },
        },
      },
    }
    ---@type MasonLspconfigSettings
    ---@diagnostic disable-next-line: missing-fields
    require("mason-lspconfig").setup({
      automatic_enable = vim.tbl_keys(servers or {}),
    })

    capabilities = vim.tbl_deep_extend("force", capabilities, blink_capabilities)

    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      "stylua",
      "black",
      "shfmt",
      "prettierd",
      "prettier",
      -- "xmlformatter",
      -- "yamlfmt",

      -- Linters
      "markdownlint",
      "hadolint",
      "jsonlint",
    })
    require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

    for server_name, config in pairs(servers) do
      vim.lsp.config(server_name, config)
    end
  end,
}
