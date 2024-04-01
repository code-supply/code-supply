local elixir = require 'elixir'

return {
  setup = function(capabilities, on_attach)
    elixir.setup {
      elixirls = {
        on_attach = on_attach,
        cmd = { "elixir-ls" },
        capabilities = capabilities
      },
      credo = {
        on_attach = on_attach,
        capabilities = capabilities
      }
    }
  end
}
