local elixir = require 'elixir'

return {
  setup = function(capabilities)
    elixir.setup {
      elixirls = {
        cmd = { "elixir-ls" },
        capabilities = capabilities
      },
      credo = {
        version = "0.3.0",
        capabilities = capabilities
      }
    }
  end
}
