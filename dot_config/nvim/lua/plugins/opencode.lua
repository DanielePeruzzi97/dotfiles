return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {}

    -- Required for buffer auto-reload when opencode edits files
    vim.o.autoread = true

    -- Toggle opencode window
    vim.keymap.set({ "n", "t" }, "<leader>ot", function()
      require("opencode").toggle()
    end, { desc = "[O]pencode [T]oggle" })

    -- Ask (open input prompt)
    vim.keymap.set("n", "<leader>oA", function()
      require("opencode").ask()
    end, { desc = "[O]pencode [A]sk" })

    -- Ask about current context (cursor position or visual selection)
    vim.keymap.set({ "n", "x" }, "<leader>oa", function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = "[O]pencode [A]sk @this" })

    -- Select from all opencode functionality
    vim.keymap.set({ "n", "x" }, "<leader>os", function()
      require("opencode").select()
    end, { desc = "[O]pencode [S]elect prompt" })

    -- New session
    vim.keymap.set("n", "<leader>on", function()
      require("opencode").command("session.new")
    end, { desc = "[O]pencode [N]ew session" })

    -- Share session
    vim.keymap.set("n", "<leader>oy", function()
      require("opencode").command("session.share")
    end, { desc = "[O]pencode [Y]ank/share session" })

    -- Document selection (uses built-in prompt)
    vim.keymap.set({ "n", "x" }, "<leader>od", function()
      require("opencode").prompt("document")
    end, { desc = "[O]pencode [D]ocument" })

    -- Fix diagnostics (uses built-in prompt)
    vim.keymap.set("n", "<leader>of", function()
      require("opencode").prompt("fix")
    end, { desc = "[O]pencode [F]ix diagnostics" })

    -- Review current context (uses built-in prompt)
    vim.keymap.set({ "n", "x" }, "<leader>or", function()
      require("opencode").prompt("review")
    end, { desc = "[O]pencode [R]eview" })
  end,
}
