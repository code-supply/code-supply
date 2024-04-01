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

-- format before save
vim.api.nvim_create_autocmd('BufWritePre', {
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
