local opts = { noremap=true, silent=true }
local wk = require('which-key')
vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
vim.api.nvim_set_keymap('n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

local builtin = require("telescope.builtin")

wk.register({
    ["<leader>ff"] = { builtin.find_files, "Find files"},
    ["<leader>fg"] = { builtin.live_grep, "Live Grep" },
    ["<leader>fb"] = { builtin.buffers, "Find Buffers"},
    ["<leader>fh"] = { builtin.help_tags, "Find Help Tags"},
}, opts)

