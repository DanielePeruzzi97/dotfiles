return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "letieu/harpoon-lualine",
  },
  event = "ColorScheme",
  config = function()
    local lualine = require("lualine")

    local config = {
      options = {
        theme = "auto",
        section_separators = "",
        component_separators = "",
        icons_enabled = false,
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
    }

    -- Helper functions
    local function ins_left(component)
      table.insert(config.sections.lualine_c, component)
    end

    local function ins_right(component)
      table.insert(config.sections.lualine_x, component)
    end

    -- Left side components
    ins_left({
      "mode",
      padding = { right = 1 },
    })

    ins_left({
      "filename",
      cond = function()
        return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
      end,
    })

    ins_left({
      "diagnostics",
      sources = { "nvim_diagnostic" },
    })

    ins_left({
      "harpoon2",
    })

    ins_left({
      function()
        return "%="
      end,
    })

    -- Right side components
    ins_right({
      "branch",
    })

    ins_right({
      "diff",
      sources = "Gitsigns",
    })

    ins_right({
      "filetype",
    })

    lualine.setup(config)
  end,
}
