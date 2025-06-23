return {
  "rose-pine/neovim",
  priority = 1000,
  config = function()
    require("rose-pine").setup({
      styles = {
        italic = false,
        comments = { italic = false },
      },
    })
    vim.cmd.colorscheme("rose-pine")
  end,
}
