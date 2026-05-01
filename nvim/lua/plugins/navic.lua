return {
  "SmiteshP/nvim-navic",
  dependencies = "neovim/nvim-lspconfig",
  config = function()
    -- Define highlight groups for navic icons and text (only fg, no bg)
    vim.api.nvim_set_hl(0, "NavicIconsFile",          {fg = "#82AAFF", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsModule",        {fg = "#82AAFF", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsNamespace",     {fg = "#82AAFF", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsPackage",       {fg = "#82AAFF", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsClass",         {fg = "#FFC777", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsMethod",        {fg = "#C099FF", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsProperty",      {fg = "#86E1FC", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsField",         {fg = "#86E1FC", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsConstructor",   {fg = "#FFC777", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsEnum",          {fg = "#FFC777", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsInterface",     {fg = "#FFC777", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsFunction",      {fg = "#C099FF", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsVariable",      {fg = "#C099FF", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsConstant",      {fg = "#FAB387", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsString",        {fg = "#C7FB6D", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsNumber",        {fg = "#FAB387", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsBoolean",       {fg = "#FAB387", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsArray",         {fg = "#FAB387", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsObject",        {fg = "#FAB387", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsKey",           {fg = "#FF757F", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsNull",          {fg = "#828BB8", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsEnumMember",    {fg = "#86E1FC", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsStruct",        {fg = "#FFC777", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsEvent",         {fg = "#FF757F", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsOperator",      {fg = "#82AAFF", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicIconsTypeParameter", {fg = "#FFC777", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicText",               {fg = "#C8D3F5", bg = "#1E2030"})
    vim.api.nvim_set_hl(0, "NavicSeparator",          {fg = "#828BB8", bg = "#1E2030"})


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
      separator = "  ",
      depth_limit = 0,
      depth_limit_indicator = "...",
      safe_output = true,
      lazy_update_context = false,
      click = false,
      format_text = function(text)
        return text
      end
    }
  end
}

