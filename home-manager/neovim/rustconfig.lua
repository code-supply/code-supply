return {
  setup = function(lsp, capabilities, on_attach)
    lsp.rust_analyzer.setup {
      on_attach = on_attach,
      settings = {
        ["rust-analyzer"] = {
          imports = {
            granularity = {
              group = "module",
            },
            prefix = "self",
          },
          cargo = {
            buildScripts = {
              enable = true,
            },
          },
          procMacro = {
            enable = true
          },
          checkOnSave = {
            command = "clippy",
          },
        }
      }
    }
  end
}
