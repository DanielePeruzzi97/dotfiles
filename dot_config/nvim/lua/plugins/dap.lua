-- Augroup for DAP-related autocommands
vim.api.nvim_create_augroup("DapGroup", { clear = true })

-- Helper: Auto-focus on DAP UI windows when they open
local function navigate(args)
  local buffer = args.buf
  local wid = nil
  local win_ids = vim.api.nvim_list_wins()

  for _, win_id in ipairs(win_ids) do
    local win_bufnr = vim.api.nvim_win_get_buf(win_id)
    if win_bufnr == buffer then
      wid = win_id
    end
  end

  if wid == nil then
    return
  end

  vim.schedule(function()
    if vim.api.nvim_win_is_valid(wid) then
      vim.api.nvim_set_current_win(wid)
    end
  end)
end

-- Helper: Create autocmd options for auto-navigation
local function create_nav_options(name)
  return {
    group = "DapGroup",
    pattern = string.format("*%s*", name),
    callback = navigate,
  }
end

return {
  "mfussenegger/nvim-dap",
  event = "VeryLazy",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "nvim-neotest/nvim-nio",
    "williamboman/mason.nvim",
    "jay-babu/mason-nvim-dap.nvim",
  },
  config = function()
    local dap = require("dap")
    local ui = require("dapui")
    local virtual_text = require("nvim-dap-virtual-text")
    local mason_dap = require("mason-nvim-dap")

    -- Enable debug logging for troubleshooting
    dap.set_log_level("DEBUG")

    -- Setup virtual text (inline variable display)
    virtual_text.setup()

    -- Setup mason-nvim-dap with default handlers for all adapters
    mason_dap.setup({
      ensure_installed = {
        "bash-debug-adapter",
        "python",
        "delve",
      },
      automatic_installation = true,
      handlers = {
        function(config)
          require("mason-nvim-dap").default_setup(config)
        end,
      },
    })

    -- Core debug keybindings (always available)
    vim.keymap.set("n", "<F8>", dap.continue, { desc = "Continue" })
    vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step over" })
    vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step into" })
    vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Step out" })
    vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Toggle [B]reakpoint" })
    vim.keymap.set("n", "<leader>B", function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end, { desc = "Conditional [B]reakpoint" })

    -- Layouts configuration:
    -- Layout 1: Default left sidebar (for full UI)
    -- Layout 2: Default bottom panel (for full UI)
    -- Layouts 3-8: Individual elements at bottom
    ui.setup({
      layouts = {
        -- Layout 1: Left sidebar (default full UI)
        {
          elements = {
            { id = "scopes", size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks", size = 0.25 },
            { id = "watches", size = 0.25 },
          },
          position = "left",
          size = 40,
        },
        -- Layout 2: Bottom panel (default full UI)
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          position = "bottom",
          size = 10,
        },
        -- Layout 3-8: Individual elements (bottom, 40% height)
        { elements = { { id = "scopes" } }, position = "bottom", size = 0.4 },
        { elements = { { id = "stacks" } }, position = "bottom", size = 0.4 },
        { elements = { { id = "breakpoints" } }, position = "bottom", size = 0.4 },
        { elements = { { id = "watches" } }, position = "bottom", size = 0.4 },
        { elements = { { id = "repl" } }, position = "bottom", size = 0.4 },
        { elements = { { id = "console" } }, position = "bottom", size = 0.4 },
      },
    })

    -- Layout indices for individual elements
    local element_layout = {
      scopes = 3,
      stacks = 4,
      breakpoints = 5,
      watches = 6,
      repl = 7,
      console = 8,
    }

    -- Track currently open individual layout (nil = none or full UI)
    local current_element = nil

    -- Toggle individual element at bottom
    local function toggle_element(name)
      -- Close full UI if open
      ui.close({ layout = 1 })
      ui.close({ layout = 2 })

      if current_element == name then
        -- Same element: close it
        ui.close({ layout = element_layout[name] })
        current_element = nil
      else
        -- Different element: close current, open new
        if current_element then
          ui.close({ layout = element_layout[current_element] })
        end
        ui.open({ layout = element_layout[name] })
        current_element = name
      end
    end

    -- Toggle full UI (layouts 1 and 2)
    local function toggle_full_ui()
      -- Close any individual element first
      if current_element then
        ui.close({ layout = element_layout[current_element] })
        current_element = nil
      end
      ui.toggle({ layout = 1 })
      ui.toggle({ layout = 2 })
    end

    -- Session-aware debug UI keymaps (only available during debugging)
    local debug_keymaps = {
      {
        "n",
        "<leader>ds",
        function()
          toggle_element("scopes")
        end,
        "[D]ebug [S]copes",
      },
      {
        "n",
        "<leader>dt",
        function()
          toggle_element("stacks")
        end,
        "[D]ebug S[t]acks",
      },
      {
        "n",
        "<leader>db",
        function()
          toggle_element("breakpoints")
        end,
        "[D]ebug [B]reakpoints",
      },
      {
        "n",
        "<leader>dw",
        function()
          toggle_element("watches")
        end,
        "[D]ebug [W]atches",
      },
      {
        "n",
        "<leader>dr",
        function()
          toggle_element("repl")
        end,
        "[D]ebug [R]EPL",
      },
      {
        "n",
        "<leader>dc",
        function()
          toggle_element("console")
        end,
        "[D]ebug [C]onsole",
      },
      {
        "n",
        "<leader>de",
        function()
          ui.eval()
        end,
        "[D]ebug [E]val expression",
      },
      { "n", "<leader>du", toggle_full_ui, "[D]ebug toggle [U]I" },
    }

    local function setup_debug_keymaps()
      for _, map in ipairs(debug_keymaps) do
        vim.keymap.set(map[1], map[2], map[3], { desc = map[4] })
      end
    end

    local function teardown_debug_keymaps()
      for _, map in ipairs(debug_keymaps) do
        pcall(vim.keymap.del, map[1], map[2])
      end
    end

    -- Autocmds: REPL wrap and auto-focus
    vim.api.nvim_create_autocmd("BufEnter", {
      group = "DapGroup",
      pattern = "*dap-repl*",
      callback = function()
        vim.wo.wrap = true
      end,
    })

    vim.api.nvim_create_autocmd("BufWinEnter", create_nav_options("dap-repl"))
    vim.api.nvim_create_autocmd("BufWinEnter", create_nav_options("DAP Watches"))

    -- DAP Listeners
    -- Setup debug keymaps and open full UI when session starts
    dap.listeners.after.event_initialized["debug_keymaps"] = function()
      setup_debug_keymaps()
      ui.open({ layout = 1 }) -- Left sidebar (scopes, breakpoints, stacks, watches)
      ui.open({ layout = 2 }) -- Bottom panel (repl, console)
    end

    -- Close UI and teardown keymaps on debug end
    dap.listeners.before.event_terminated.dapui_config = function()
      ui.close()
      teardown_debug_keymaps()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      ui.close()
      teardown_debug_keymaps()
    end
  end,
}
