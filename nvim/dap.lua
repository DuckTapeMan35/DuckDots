return {
  {
    "mfussenegger/nvim-dap",
    config = function()
      -- Basic configuration
      local dap = require("dap")

      -- Add some keybindings for debugging
      vim.keymap.set('n', '<F5>', dap.continue, { desc = "Start/Continue Debugging" })
      vim.keymap.set('n', '<F10>', dap.step_over, { desc = "Step Over" })
      vim.keymap.set('n', '<F11>', dap.step_into, { desc = "Step Into" })
      vim.keymap.set('n', '<F12>', dap.step_out, { desc = "Step Out" })
      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
    end,
  },
}

