return {
  setup = function(lsp, capabilities, on_attach)
    lsp.nil_ls.setup {
      on_attach = on_attach,
      settings = {
        ["nil"] = {
          formatting = {
            command = { "nixpkgs-fmt" }
          }
        }
      },
      capabilities = capabilities
    }
  end
}
