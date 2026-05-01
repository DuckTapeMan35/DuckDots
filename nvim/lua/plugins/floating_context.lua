return {
  "iicsx/nvim-fox",
  branch = "main",
  opts = {
    context = {
      enable = true,
    },
  },
  keys = {
    {"<leader>fo", ":FoxOpen<cr>", desc = "Open floating context window", mode = {"v"} },
    {"<leader>fc", ":FoxClose<cr>", desc = "Close floating context window", mode = {"n"} },
    {"<leader>fs", ":FoxSticky<cr>", desc = "Open floating context window", mode = {"n"} },
  }
}
