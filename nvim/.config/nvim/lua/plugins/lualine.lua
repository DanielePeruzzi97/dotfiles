return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "AndreM222/copilot-lualine",
    "letieu/harpoon-lualine",
  },
  event = "ColorScheme",
  config = function()
    local colors = {
      bg = "#191724", -- base
      fg = "#e0def4", -- text
      rose = "#ebbcba",
      pine = "#31748f",
      foam = "#9ccfd8",
      iris = "#c4a7e7",
      gold = "#f6c177",
      love = "#eb6f92",
      muted = "#6e6a86",
    }

    local lualine = require("lualine")

    local config = {
      options = {
        theme = {
          normal = { c = { fg = colors.fg, bg = colors.bg } },
          inactive = { c = { fg = colors.muted, bg = colors.bg } },
        },
        section_separators = "",
        component_separators = "",
        icons_enabled = true,
        globalstatus = true,
      },
      sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { "filename" },
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      -- extensions = { "oil", "lazy", "mason" },
    }

    -- helpers
    local function ins_left(component)
      table.insert(config.sections.lualine_c, component)
    end
    local function ins_right(component)
      table.insert(config.sections.lualine_x, component)
    end

    -- LEFT SIDE
    ins_left({
      -- mode letter
      function()
        return vim.fn.mode():sub(1, 1):upper()
      end,
      color = function()
        local mode_color = {
          n = colors.rose,
          i = colors.foam,
          v = colors.iris,
          V = colors.iris,
          [""] = colors.iris,
          R = colors.love,
          c = colors.gold,
          t = colors.pine,
        }
        return { fg = mode_color[vim.fn.mode()] or colors.fg, bg = colors.bg, gui = "bold" }
      end,
      padding = { right = 1 },
    })

    ins_left({
      "filename",
      color = { fg = colors.fg },
      cond = function()
        return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
      end,
    })

    ins_left({
      "diagnostics",
      sources = { "nvim_diagnostic" },
      diagnostics_color = {
        error = { fg = colors.love },
        warn = { fg = colors.gold },
        info = { fg = colors.foam },
      },
    })

    ins_left({
      "harpoon2",
      icon = "",
    })

    ins_left({
      function()
        return "%="
      end,
    })

    ins_right({
      "branch",
      color = { fg = colors.iris },
    })

    ins_right({
      "diff",
      diff_color = {
        added = { fg = colors.foam },
        modified = { fg = colors.gold },
        removed = { fg = colors.love },
      },
      sources = "Gitsigns",
    })

    ins_right({
      "copilot",
      icon = "",
      color = { fg = colors.fg },
      symbols = {
        status = {
          icons = {
            enabled = " ",
            sleep = " ",
            disabled = " ",
            warning = " ",
            unknown = " ",
          },
        },
      },
    })

    ins_right({
      "filetype",
      icon_only = false,
      color = { fg = colors.muted },
    })

    lualine.setup(config)
  end,
}
