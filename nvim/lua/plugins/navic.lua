return {
  "SmiteshP/nvim-navic",
  dependencies = "neovim/nvim-lspconfig",
  config = function()
    -- Define highlight groups for navic icons and text (only fg, no bg)
    vim.api.nvim_set_hl(0, "NavicIconsFile",          {fg = "#89b4fa", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsModule",        {fg = "#89b4fa", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsNamespace",     {fg = "#89b4fa", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsPackage",       {fg = "#89b4fa", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsClass",         {fg = "#f9e2af", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsMethod",        {fg = "#cba6f7", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsProperty",      {fg = "#94e2d5", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsField",         {fg = "#94e2d5", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsConstructor",   {fg = "#f9e2af", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsEnum",          {fg = "#f9e2af", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsInterface",     {fg = "#f9e2af", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsFunction",      {fg = "#cba6f7", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsVariable",      {fg = "#cba6f7", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsConstant",      {fg = "#fab387", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsString",        {fg = "#a6e3a1", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsNumber",        {fg = "#fab387", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsBoolean",       {fg = "#fab387", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsArray",         {fg = "#fab387", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsObject",        {fg = "#fab387", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsKey",           {fg = "#f38ba8", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsNull",          {fg = "#585b70", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsEnumMember",    {fg = "#94e2d5", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsStruct",        {fg = "#f9e2af", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsEvent",         {fg = "#f38ba8", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsOperator",      {fg = "#89b4fa", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsTypeParameter", {fg = "#f9e2af", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicText",               {fg = "#cdd6f4", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicSeparator",          {fg = "#585b70", bg = "#1E2030"})


    local navic = require("nvim-navic")
    navic.setup {
      icons = {
        File = "󰈙 ",
        Module = " ",
        Namespace = "󰌗 ",
        Package = " ",
        Class = "󰌗 ",
        Method = "󰆧 ",
        Property = " ",
        Field = " ",
        Constructor = " ",
        Enum = "󰕘",
        Interface = "󰕘",
        Function = "󰊕 ",
        Variable = "󰆧 ",
        Constant = "󰏿 ",
        String = "󰀬 ",
        Number = "󰎠 ",
        Boolean = "◩ ",
        Array = "󰅪 ",
        Object = "󰅩 ",
        Key = "󰌋 ",
        Null = "󰟢 ",
        EnumMember = " ",
        Struct = "󰌗 ",
        Event = " ",
        Operator = "󰆕 ",
        TypeParameter = "󰊄 ",
      },
      lsp = {
        auto_attach = true,
        preference = nil,
      },
      highlight = true,
      separator = "  ",
      depth_limit = 0,
      depth_limit_indicator = "..",
      safe_output = true,
      lazy_update_context = false,
      click = false,
      format_text = function(text)
        return text
      end
    }
  end
}

