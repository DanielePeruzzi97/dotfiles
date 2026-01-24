return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = "1.*",
  dependencies = {
    "xzbdmw/colorful-menu.nvim",
    "folke/lazydev.nvim",
  },
  opts = {
    keymap = {
      preset = "super-tab",
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
    },

    fuzzy = {
      implementation = "prefer_rust_with_warning",
    },

    appearance = {
      nerd_font_variant = "mono",
      kind_icons = {
        Snippet = "",
      },
    },

    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 500,
      },
      ghost_text = {
        enabled = false, -- handled by copilot.lua
      },
      menu = {
        min_width = 20,
        border = "rounded",
        winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpMenuSelection,Search:None",
        draw = {
          columns = { { "kind_icon" }, { "label", gap = 1 }, { "source" } },
          components = {
            label = {
              text = function(ctx)
                return require("colorful-menu").blink_components_text(ctx)
              end,
              highlight = function(ctx)
                return require("colorful-menu").blink_components_highlight(ctx)
              end,
            },
            source = {
              text = function(ctx)
                local map = {
                  ["lsp"] = "[]",
                  ["path"] = "[󰉋]",
                  ["snippets"] = "[]",
                }
                return map[ctx.item.source_id]
              end,
              highlight = "BlinkCmpDoc",
            },
          },
        },
      },
    },
  },

  snippets = {
    preset = "luasnip",
  },

  sources = {
    default = { "lsp", "path", "snippets", "buffer", "lazydev" },
    providers = {
      lazydev = {
        module = "lazydev.integrations.blink",
        score_offset = 100,
        fallbacks = { "lsp" },
      },
    },
  },

  signature = {
    enabled = true,
  },

  cmdline = {
    keymap = {
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<Tab>"] = { "show", "accept" },
    },
    completion = {
      menu = { auto_show = true },
    },
  },
}
