return {
    {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {
        inlay_hints = { enabled = false },
        servers = {
          clangd = {
            cmd = {
              "clangd",
              "--background-index",
              "--clang-tidy",
              "--header-insertion=iwyu",
              "--completion-style=detailed",
              "--function-arg-placeholders",
              "--fallback-style=llvm",
              "--enable-config",
              "--compile-commands-dir=build",
            },
          },
        },
      })
    end,
  },
}
