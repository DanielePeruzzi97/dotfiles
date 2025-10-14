return {
  "rose-pine/neovim",
  priority = 1000,
  config = function()
    require("rose-pine").setup({
      disable_background = true,
      styles = {
        italic = false,
        comments = { italic = false },
      },
    })
    vim.cmd("colorscheme rose-pine")

    local black_bg = "#000000"
    local hl = vim.api.nvim_set_hl
    hl(0, "Normal", { bg = black_bg })
    hl(0, "NormalNC", { bg = black_bg })
    hl(0, "NormalFloat", { bg = black_bg })
    hl(0, "FloatBorder", { bg = black_bg })
    hl(0, "TelescopeNormal", { bg = black_bg })
    hl(0, "TelescopeBorder", { bg = black_bg })
    hl(0, "TelescopePromptNormal", { bg = black_bg })
    hl(0, "TelescopePromptBorder", { bg = black_bg })
    hl(0, "TelescopeResultsNormal", { bg = black_bg })
    hl(0, "TelescopeResultsBorder", { bg = black_bg })
    hl(0, "LazyNormal", { bg = black_bg })
    hl(0, "HarpoonWindow", { bg = black_bg })
    hl(0, "HarpoonBorder", { bg = black_bg })
  end,
}
