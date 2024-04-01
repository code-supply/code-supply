return {
  setup = function(lsp, capabilities)
    lsp.nil_ls.setup {
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
