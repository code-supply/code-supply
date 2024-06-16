return {
  setup = function(lsp, capabilities)
    lsp.nil_ls.setup {
      on_attach = function(_client)
        vim.bo.commentstring = "# %s"
      end,
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
