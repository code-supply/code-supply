local lsp = require 'lspconfig'
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local on_attach = require 'onattach'
require 'completion'
require 'fidgetconfig'
require 'elixirconfig'.setup(capabilities, on_attach)
require 'treesitter'

require('Comment').setup()

vim.api.nvim_exec([[ autocmd vimenter * ++nested colorscheme gruvbox ]], false)

vim.opt.termguicolors = true
vim.opt.mouse = 'a'
vim.opt.number = true
vim.g.mapleader = ","
vim.g.maplocalleader = ","
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.o.wrap = false

-- ctrl-hjkl pane movement
vim.api.nvim_set_keymap('n', '<c-h>', '<c-w>h', { noremap = true })
vim.api.nvim_set_keymap('n', '<c-j>', '<c-w>j', { noremap = true })
vim.api.nvim_set_keymap('n', '<c-k>', '<c-w>k', { noremap = true })
vim.api.nvim_set_keymap('n', '<c-l>', '<c-w>l', { noremap = true })

-- quick quit buffer
vim.api.nvim_set_keymap('n', '<leader>q', ':q<cr>', { noremap = true })

-- clear highlighting with space
vim.api.nvim_set_keymap('n', '<space>', ':nohlsearch<cr>', { noremap = true })

-- telescope
vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>a', '<cmd>Telescope grep_string<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>fo', '<cmd>Telescope oldfiles<cr>', { noremap = true })

-- vim-test
vim.g["test#strategy"] = "kitty"
vim.g["test#custom_transformations"] = {
  direnv = function(cmd)
    return 'direnv exec "$(git rev-parse --show-toplevel)" ' .. cmd
  end
}
vim.g["test#transformation"] = "direnv"

vim.api.nvim_set_keymap('n', '<F9>', ':w<cr>:TestNearest<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F12>', ':w<cr>:TestFile<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F11>', ':w<cr>:TestNearest<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F10>', ':w<cr>:TestLast<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F8>', ':w<cr>:TestVisit<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F7>', ':w<cr>:TestSuite<cr>', { noremap = true })

-- sort lists inside []
vim.api.nvim_set_keymap('n', '<F5>', '!i[sort<cr>', { noremap = true })

-- format before save
vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

lsp.lua_ls.setup {
  on_attach = on_attach,
  capabilities = capabilities,

  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
      client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
        Lua = {
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME
              -- "${3rd}/luv/library"
              -- "${3rd}/busted/library",
            }
            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
            -- library = vim.api.nvim_get_runtime_file("", true)
          }
        }
      })

      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
    return true
  end
}

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
