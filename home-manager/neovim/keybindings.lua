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

-- sort lists inside []
vim.api.nvim_set_keymap('n', '<F5>', '!i[sort<cr>', { noremap = true })

-- vim-test
vim.api.nvim_set_keymap('n', '<F7>', ':w<cr>:TestSuite<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F8>', ':w<cr>:TestVisit<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F10>', ':w<cr>:TestLast<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F11>', ':w<cr>:TestNearest<cr>', { noremap = true })
vim.api.nvim_set_keymap('n', '<F12>', ':w<cr>:TestFile<cr>', { noremap = true })

-- diagnostics
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)
