return {
  {
    "nvim-mini/mini.ai",
    config = function()
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require("mini.ai").setup({ n_lines = 500 })
    end,
  },
  {
    "nvim-mini/mini.surround",
    config = function()
      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require("mini.surround").setup()
    end,
  },
  {
    "nvim-mini/mini.pairs",
    config = function()
      require("mini.pairs").setup()
    end,
  },
  {
    "nvim-mini/mini.statusline",
    config = function()
      local statusline = require("mini.statusline")
      
      -- Rose-pine colors (matching your theme)
      local colors = {
        text = "#e0def4",
        rose = "#ebbcba",
        pine = "#31748f",
        foam = "#9ccfd8",
        iris = "#c4a7e7",
        gold = "#f6c177",
        love = "#eb6f92",
        muted = "#6e6a86",
      }
      
      statusline.setup({
        use_icons = vim.g.have_nerd_font,
        set_vim_settings = false,
      })
      
      -- Mode with single letter (matching lualine)
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_mode = function(args)
        local mode = vim.fn.mode():sub(1, 1):upper()
        return mode
      end
      
      -- Filename section
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_filename = function(args)
        if vim.bo.buftype ~= "" then
          return "%f"
        end
        return "%f%m%r" -- filename, modified flag, readonly flag
      end
      
      -- Git section
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_git = function(args)
        local summary = vim.b.gitsigns_status_dict or {}
        if vim.tbl_isempty(summary) then
          return ""
        end
        
        local parts = {}
        if summary.head then
          table.insert(parts, " " .. summary.head)
        end
        if summary.added and summary.added > 0 then
          table.insert(parts, "+" .. summary.added)
        end
        if summary.changed and summary.changed > 0 then
          table.insert(parts, "~" .. summary.changed)
        end
        if summary.removed and summary.removed > 0 then
          table.insert(parts, "-" .. summary.removed)
        end
        
        if #parts == 0 then
          return ""
        end
        return table.concat(parts, " ")
      end
      
      -- Diagnostics section
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_diagnostics = function(args)
        local counts = vim.diagnostic.count(0)
        local parts = {}
        
        if counts[vim.diagnostic.severity.ERROR] then
          table.insert(parts, "󰅚 " .. counts[vim.diagnostic.severity.ERROR])
        end
        if counts[vim.diagnostic.severity.WARN] then
          table.insert(parts, "󰀪 " .. counts[vim.diagnostic.severity.WARN])
        end
        if counts[vim.diagnostic.severity.INFO] then
          table.insert(parts, "󰋽 " .. counts[vim.diagnostic.severity.INFO])
        end
        
        if #parts == 0 then
          return ""
        end
        return table.concat(parts, " ")
      end
      
      -- LSP section (show active LSP clients)
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_lsp = function(args)
        local buf_clients = vim.lsp.get_clients({ bufnr = 0 })
        if #buf_clients == 0 then
          return ""
        end
        
        local client_names = {}
        for _, client in ipairs(buf_clients) do
          if client.name ~= "null-ls" and client.name ~= "copilot" then
            table.insert(client_names, client.name)
          end
        end
        
        if #client_names == 0 then
          return ""
        end
        
        return " " .. table.concat(client_names, ",")
      end
      
      -- Harpoon section (show harpoon marks)
      local function harpoon_section()
        local ok, harpoon = pcall(require, "harpoon")
        if not ok then
          return ""
        end
        
        local marks = harpoon:list()
        if not marks or marks:length() == 0 then
          return ""
        end
        
        local current_file = vim.api.nvim_buf_get_name(0)
        local marks_str = {}
        
        for i = 1, math.min(5, marks:length()) do
          local mark = marks:get(i)
          if mark and mark.value then
            if mark.value == current_file then
              table.insert(marks_str, string.format("[%d]", i))
            else
              table.insert(marks_str, tostring(i))
            end
          end
        end
        
        if #marks_str == 0 then
          return ""
        end
        
        return " " .. table.concat(marks_str, " ")
      end
      
      -- Location section (line:col)
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return "%2l:%-2v"
      end
      
      -- Combine sections (mimicking lualine layout)
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.combine_groups = function(groups)
        local mode = groups.mode or ""
        local filename = groups.filename or ""
        local diagnostics = groups.diagnostics or ""
        local lsp = statusline.section_lsp() or ""
        local harpoon = harpoon_section() or ""
        local git = groups.git or ""
        local fileinfo = groups.fileinfo or ""
        local location = groups.location or ""
        
        return string.format(
          "%s %s %s%s%s%%=%s %s %s",
          mode,
          filename,
          diagnostics,
          harpoon,
          lsp,
          git,
          fileinfo,
          location
        )
      end
    end,
  },
  {
    "nvim-mini/mini.splitjoin",
    config = function()
      -- - gS to splijoin
      require("mini.splitjoin").setup()
    end,
  },
}
