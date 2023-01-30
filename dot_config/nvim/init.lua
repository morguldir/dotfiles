require('plugins')
require('options')
require('mappings')
local set = vim.opt

set.expandtab = true
set.shiftwidth = 4
set.tabstop = 4

function map(mode, shortcut, command)
    vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true})
end

function nmap(shortcut, command)
    map('n', shortcut, command)
end

nmap("<F8>", "<cmd>TagbarToggle<CR>")
nmap("<F7>", "<cmd>NERDTreeToggle<CR>")
nmap("<F9>", "<cmd>ToggleBufExplorer<CR>")
nmap("<Leader>r", ":source $MYVIMRC<CR>")

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = true,
  severity_sort = false,
})

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions

