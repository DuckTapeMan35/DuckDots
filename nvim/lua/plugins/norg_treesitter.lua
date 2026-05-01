return {
  "nvim-treesitter/nvim-treesitter",
  opts = function()
    vim.treesitter.language.register("norg", "norg")

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "norg",
      callback = function()
        vim.treesitter.start()
      end,
    })
  end,
}
