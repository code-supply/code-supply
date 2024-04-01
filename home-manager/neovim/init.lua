require 'preferences'
require 'keybindings'
require 'appearance'
local lsp = require 'lspconfig'
local capabilities = require 'cmp_nvim_lsp'.default_capabilities()
local on_attach = require 'onattach'
require 'completion'
require 'fidgetconfig'
require 'treesitter'
require 'elixirconfig'.setup(capabilities, on_attach)
require 'luaconfig'.setup(lsp, capabilities, on_attach)
require 'Comment'.setup()
require 'vimtest'

lsp.tsserver.setup {
  on_attach = on_attach,
  cmd = {
    "typescript-language-server",
    "--stdio",
    "--tsserver-path",
    "/nix/store/knd3r0pazcban9yz22sv39rmqi95bbrn-typescript-4.8.4/lib/node_modules/typescript/lib"
  }
}

lsp.eslint.setup {
  on_attach = on_attach,
}

lsp.idris2_lsp.setup {}

lsp.terraform_lsp.setup {}
vim.g.terraform_fmt_on_save = "1"

if vim.fn.executable('tailwindcss-language-server') == 1 then
  lsp.tailwindcss.setup {}
end

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
