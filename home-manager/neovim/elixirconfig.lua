local elixir = require 'elixir'

return {
  setup = function(capabilities)
    elixir.setup {
      elixirls = {
        cmd = { "elixir-ls" },
        capabilities = capabilities
      },
      credo = {
        capabilities = capabilities
      }
    }
  end
}
