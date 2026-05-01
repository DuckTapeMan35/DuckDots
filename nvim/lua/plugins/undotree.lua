return {
  "mbbill/undotree",
  keys = {
    -- Keymap to toggle Undotree
    { "<leader>U", "<cmd>UndotreeToggle<cr>", desc = "UndoTree Toggle" },
  },
  config = function()
    -- Optional: Set Undotree window layout (example: open on the right)
    vim.g.undotree_WindowLayout = 3
  end
}
