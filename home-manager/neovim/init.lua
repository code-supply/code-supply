local lsp = require 'lspconfig'
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local cmp = require 'cmp'
local elixir = require 'elixir'

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

-- completion
cmp.setup({
  mapping = {
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' }
  })
})

require 'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
}

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap = true, silent = true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<leader>k', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('v', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.show()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  buf_set_keymap('n', '<space>f', '<cmd>lua vim.lsp.buf.format()<CR>', opts)
  buf_set_keymap('n', '<leader><F6>', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
end

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
