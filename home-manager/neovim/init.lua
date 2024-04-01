local lsp = require 'lspconfig'
local capabilities = require 'cmp_nvim_lsp'.default_capabilities()

require 'preferences'
require 'keybindings'
require 'onattach'
require 'appearance'
require 'completion'
require 'fidgetconfig'
require 'treesitter'
require 'Comment'.setup()
require 'vimtest'

require 'elixirconfig'.setup(capabilities)
require 'luaconfig'.setup(lsp, capabilities)
require 'nixconfig'.setup(lsp, capabilities)
require 'rustconfig'.setup(lsp)

lsp.idris2_lsp.setup {}
lsp.terraform_lsp.setup {}
vim.g.terraform_fmt_on_save = "1"

if vim.fn.executable('tailwindcss-language-server') == 1 then
  lsp.tailwindcss.setup {}
end
