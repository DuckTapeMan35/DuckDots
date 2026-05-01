return {
  {
    "SmiteshP/nvim-navbuddy",
    dependencies = {
      "neovim/nvim-lspconfig",
      "SmiteshP/nvim-navic",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      lsp = { auto_attach = true },
    },
    keys = {
      { "<leader>cn", function() require("nvim-navbuddy").open() end, desc = "Open Navbuddy" },
    },
  },
}

