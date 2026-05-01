return {
  "nvim-neorg/neorg",
  dependencies = {
    "vhyrro/luarocks.nvim",
    "nvim-neorg/tree-sitter-norg",
    "nvim-treesitter/nvim-treesitter",
    'nvim-neorg/tree-sitter-norg-meta',
  },
  lazy = false,
  config = function()
    require("neorg").setup {
      load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {
          config = {
            icons = {
              code_block = {
                conceal = false,
              },
            },
          },
        },
        ["core.dirman"] = {
          config = {
            workspaces = {
              school = "~/school",
            },
          },
        },
        ["core.dirman.utils"] = {},
        ["core.integrations.treesitter"] = {},
        ["core.ui"] = {},
        ["core.esupports.hop"] = {
          config = {
            external_filetypes = {"pdf"},
          },
        },
      },
    }
  end,
}
