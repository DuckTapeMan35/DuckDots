return {
  {
    "AlphaTechnolog/pywal.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("pywal").setup()

      -- your pywal reload watcher
      local pywal_cache = vim.fn.expand("~/.cache/wal/colors.json")
      local watcher = vim.loop.new_fs_event()

      local function reload_colors()
        local ok, err = pcall(function()
          require("pywal").setup()
          vim.notify("Pywal colors updated!", vim.log.levels.INFO)
        end)
        if not ok then
          vim.notify("Pywal reload error: " .. tostring(err), vim.log.levels.ERROR)
        end
      end

      if vim.fn.filereadable(pywal_cache) == 1 then
        watcher:start(
          pywal_cache,
          {},
          vim.schedule_wrap(reload_colors)
        )
      else
        vim.notify("Pywal cache not found: " .. pywal_cache, vim.log.levels.WARN)
      end
    end,
  },
}

