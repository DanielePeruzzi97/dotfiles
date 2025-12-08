return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    vim.o.autoread = true

    vim.keymap.set("n", "<leader>ot", function()
      require("opencode").toggle()
    end, { desc = "[O]pencode [T]oggle" })

    vim.keymap.set("n", "<leader>oA", function()
      require("opencode").ask()
    end, { desc = "[O]pencode [A]sk" })

    vim.keymap.set({ "n", "v" }, "<leader>oa", function()
      require("opencode").ask("@this", { submit = true })
    end, { desc = "[O]pencode [A]sk @this" })

    vim.keymap.set("n", "<leader>os", function()
      require("opencode").select()
    end, { desc = "[O]pencode [S]elect prompt" })

    vim.keymap.set("n", "<leader>on", function()
      require("opencode").command("session_new")
    end, { desc = "[O]pencode [N]ew session" })

    vim.keymap.set("n", "<leader>oy", function()
      require("opencode").command("messages_copy")
    end, { desc = "[O]pencode [Y]ank message" })
  end,
}
