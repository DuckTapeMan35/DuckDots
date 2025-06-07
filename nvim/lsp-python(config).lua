require("lspconfig").pyright.setup{
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true,
      },
    },
  },
  capabilities = {
    textDocument = {
      positionEncoding = 2, -- UTF-16 encoding
    },
  },
}

