return {
  "m4xshen/hardtime.nvim",
  lazy = false,
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    -- Maximum time (in milliseconds) to consider key presses as repeated
    max_time = 1000,
    -- Maximum count of repeated key presses allowed within the max_time period
    max_count = 4,
    -- Disable mouse support to force keyboard usage
    disable_mouse = true,
    -- Enable hint messages for better commands
    hint = true,
    -- Enable notification messages for restricted and disabled keys
    notification = true,
    -- Block repeated keys instead of just hinting
    restriction_mode = "block",
    -- Disable arrow keys completely to force hjkl usage
    disabled_keys = {
      ["<Up>"] = { "n", "i", "v" },
      ["<Down>"] = { "n", "i", "v" },
      ["<Left>"] = { "n", "i", "v" },
      ["<Right>"] = { "n", "i", "v" },
    },
    -- Force exit insert mode if idle for too long (ThePrimeagen style)
    force_exit_insert_mode = true,
    max_insert_idle_ms = 5000, -- 5 seconds idle in insert mode will exit

    -- Custom hints for common inefficient patterns
    hints = {
      -- Encourage using - instead of k^
      ["k%^"] = {
        message = function()
          return "Use - instead of k^"
        end,
        length = 2,
      },
      -- Encourage using + instead of j^
      ["j%^"] = {
        message = function()
          return "Use + instead of j^"
        end,
        length = 2,
      },
      -- Encourage using C instead of c$
      ["c%$"] = {
        message = function()
          return "Use C instead of c$"
        end,
        length = 2,
      },
      -- Encourage using D instead of d$
      ["d%$"] = {
        message = function()
          return "Use D instead of d$"
        end,
        length = 2,
      },
      -- Encourage using Y instead of y$
      ["y%$"] = {
        message = function()
          return "Use Y instead of y$"
        end,
        length = 2,
      },
      -- Encourage change with motion instead of delete + insert
      ["d[tTfF].i"] = {
        message = function(keys)
          return "Use c" .. keys:sub(2, 3) .. " instead of " .. keys
        end,
        length = 4,
      },
      -- Encourage using S instead of cc
      ["cc"] = {
        message = function()
          return "Use S instead of cc"
        end,
        length = 2,
      },
      -- Encourage flash/search over repeated w motions
      ["wwww"] = {
        message = function()
          return "Use s (flash) or f/t to jump further!"
        end,
        length = 4,
      },
      -- Encourage flash/search over repeated b motions
      ["bbbb"] = {
        message = function()
          return "Use s (flash) or F/T to jump back!"
        end,
        length = 4,
      },
      -- Encourage better horizontal movement
      ["hhhh"] = {
        message = function()
          return "Use 0, ^, F/T, or s (flash) to move left!"
        end,
        length = 4,
      },
      -- Encourage better horizontal movement
      ["llll"] = {
        message = function()
          return "Use $, f/t, w, or s (flash) to move right!"
        end,
        length = 4,
      },
      -- Encourage flash over repeated j motions
      ["jjjjj"] = {
        message = function()
          return "Use s (flash), /, or Ctrl-d to move down!"
        end,
        length = 5,
      },
      -- Encourage flash over repeated k motions
      ["kkkkk"] = {
        message = function()
          return "Use s (flash), ?, or Ctrl-u to move up!"
        end,
        length = 5,
      },
    },
  },
  keys = {
    { "<leader>ht", "<cmd>Hardtime toggle<cr>", desc = "Toggle Hardtime" },
    { "<leader>hr", "<cmd>Hardtime report<cr>", desc = "Hardtime Report" },
  },
}
