require 'preferences'
require 'keybindings'
require 'appearance'
local lsp = require 'lspconfig'
local capabilities = require 'cmp_nvim_lsp'.default_capabilities()
local on_attach = require 'onattach'
require 'completion'
require 'fidgetconfig'
require 'treesitter'
require 'Comment'.setup()
require 'vimtest'

require 'elixirconfig'.setup(capabilities, on_attach)
require 'luaconfig'.setup(lsp, capabilities, on_attach)
require 'rustconfig'.setup(lsp, capabilities, on_attach)

lsp.idris2_lsp.setup {}

lsp.terraform_lsp.setup {}
vim.g.terraform_fmt_on_save = "1"

if vim.fn.executable('tailwindcss-language-server') == 1 then
  lsp.tailwindcss.setup {}
end

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
