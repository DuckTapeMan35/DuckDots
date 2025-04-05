return {
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    dependencies = {
      "folke/snacks.nvim"
    },
    keys = {
      { "<leader>y", "<cmd>Yazi<cr>", desc = "Open yazi at current file", mode = { "n", "v" } },
      { "<leader>-", "<cmd>Yazi cwd<cr>", desc = "Open in working directory" },
      { "<c-up>", "<cmd>Yazi toggle<cr>", desc = "Resume last session" },
    },
    opts = {
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
      },
    },
    init = function()
      vim.g.loaded_netrwPlugin = 1
    end,
  }
}
