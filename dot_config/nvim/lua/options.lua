require("mason").setup()
require("mason-lspconfig").setup()

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

-- Setup cmp
local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup({
	mapping = cmp.mapping.preset.insert({ -- Preset: ^n, ^p, ^y, ^e, you know the drill..
		["<C-d>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
                -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable() 
                -- they way you will only jump inside the snippet region
            elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
	}),
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "nvim_lsp_signature_help" },
		{ name = "nvim_lua" },
		{ name = "luasnip" },
		{ name = "path" },
	}, {
		{ name = "buffer", keyword_length = 3 },
	}),
})

require("luasnip.loaders.from_vscode").lazy_load()

local wk = require("which-key")
-- Setup buffer-local keymaps / options for LSP buffers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
local lsp_attach = function(_, buf)
	-- Example maps, set your own with vim.api.nvim_buf_set_keymap(buf, "n", <lhs>, <rhs>, { desc = <desc> })
	-- or a plugin like which-key.nvim
	-- <lhs>        <rhs>                        <desc>
    wk.register({
        ["K"] =          { vim.lsp.buf.hover,            "Hover Info" },
        ["<leader>qf"] = { vim.diagnostic.setqflist,     "Quickfix Diagnostics"},
        ["[d"]         = { vim.diagnostic.goto_prev,     "Previous Diagnostic"},
        ["]d"]         = { vim.diagnostic.goto_next,     "Next Diagnostic"},
        ["<leader>e"]  = { vim.diagnostic.open_float,    "Explain Diagnostic"},
        ["<leader>ca"] = { vim.lsp.buf.code_action,      "Code Action"},
        ["<leader>cr"] = { vim.lsp.buf.rename,           "Rename Symbol"},
        ["<leader>fs"] = { vim.lsp.buf.document_symbol,  "Document Symbols"},
        ["<leader>fS"] = { vim.lsp.buf.workspace_symbol, "Workspace Symbols"},
        ["<leader>gq"] = { vim.lsp.buf.formatting_sync,  "Format File (synchronously)"},
        ["gr"] = { vim.lsp.buf.references,       "[G]oto [R]eferences"},
        ["gD"] = { vim.lsp.buf.declaration,      "[G]oto [D]eclaration"},
        ["gd"] = { vim.lsp.buf.definition,       "[G]oto [D]efinition"},
        ["gi"] = { vim.lsp.buf.implementation,   "[G]oto [I]mplementation"},
    }, {buffer=buf,})

	vim.api.nvim_buf_set_option(buf, "formatexpr", "v:lua.vim.lsp.formatexpr()")
	vim.api.nvim_buf_set_option(buf, "omnifunc", "v:lua.vim.lsp.omnifunc")
	vim.api.nvim_buf_set_option(buf, "tagfunc", "v:lua.vim.lsp.tagfunc")

    --vim.api.nvim_buf_set_keymap(buf, 'n', 'gD', 'vim.lsp.buf.declaration', {desc = ""})
    --vim.api.nvim_buf_set_keymap(buf, 'n', 'gd', 'vim.lsp.buf.definition', {desc = ""})
    --vim.api.nvim_buf_set_keymap(buf, 'n', 'K', 'vim.lsp.buf.hover', {desc = ""})
    --vim.api.nvim_buf_set_keymap(buf, 'n', 'gi', 'vim.lsp.buf.implementation', {desc = ""})
    --vim.api.nvim_buf_set_keymap(buf, 'n', '<C-k>', 'vim.lsp.buf.signature_help', {desc = ""})
    --vim.api.nvim_buf_set_keymap(buf, 'n', '<space>wa', 'vim.lsp.buf.add_workspace_folder', {desc = ""})
    --vim.api.nvim_buf_set_keymap(buf, 'n', '<space>wr', 'vim.lsp.buf.remove_workspace_folder', {desc = ""})
    --vim.api.nvim_buf_set_keymap(buf, 'n', '<space>wl', 'print(vim.inspect(vim.lsp.buf.list_workspace_folders))', {desc = ""})
    --vim.api.nvim_buf_set_keymap(buf, 'n', '<space>D', 'vim.lsp.buf.type_definition', {desc = ""})
    --vim.api.nvim_buf_set_keymap(buf, 'n', '<space>rn', 'vim.lsp.buf.rename', {desc = ""})
    --vim.api.nvim_buf_set_keymap(buf, 'n', '<space>ca', 'vim.lsp.buf.code_action', {desc = ""})
    --vim.api.nvim_buf_set_keymap(buf, 'n', 'gr', 'vim.lsp.buf.references', {desc = ""})
    --vim.api.nvim_buf_set_keymap(buf, 'n', '<space>f', 'vim.lsp.buf.formatting', {desc = ""})
end

require("neodev").setup({

})

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'pyright', 'gopls', 'hls', 'ccls' }
for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
      capabilities = capabilities,
      on_attach = lsp_attach,
  }
end

require('lspconfig').sumneko_lua.setup {
    on_attach = lsp_attach,
    capabilities = capabilities,
    settings = {
        Lua = {
            completion = {
                callSnippet = "Replace"
            },
           -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
}

-- Setup rust_analyzer via rust-tools.nvim
require("rust-tools").setup({
	server = {
        capabilities = capabilities,
		on_attach = lsp_attach,
	}
})

require('telescope').setup {
    extensions = {
        ["fzf"] = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
        },
        ["ui-select"] = {
            require("telescope.themes").get_dropdown{
            }
        }
    }
}

local extensions = {"ui-select", "fzf"}
for _, extension in pairs(extensions) do
    require("telescope").load_extension(extension)
end

-- vim.opt.foldmethod     = 'expr'
-- vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
---WORKAROUND
vim.api.nvim_create_autocmd({'BufEnter','BufAdd','BufNew','BufNewFile','BufWinEnter'}, {
  group = vim.api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
  callback = function()
    vim.opt.foldmethod     = 'expr'
    vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
  end
})
---ENDWORKAROUND

require('lualine').setup{
  options = {
    theme = 'tokyonight',
  },
  sections = {lualine_c = {require('auto-session-library').current_session_name}}
}

vim.cmd[[colorscheme tokyonight]]
-- Test
vim.o.sessionoptions="blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"

require("auto-session").setup {
  log_level = "error",
  auto_session_enabled = true,
  auto_save_enabled = true,
  auto_restore_enabled = true,

  cwd_change_handling = {
    restore_upcoming_session = true, -- already the default, no need to specify like this, only here as an example
    pre_cwd_changed_hook = nil, -- already the default, no need to specify like this, only here as an example
    post_cwd_changed_hook = function() -- example refreshing the lualine status line _after_ the cwd changes
      require("lualine").refresh() -- refresh lualine so the new session name is displayed in the status bar
    end,
  },
}

vim.o.undofile = true
vim.o.mouse = 'a'
vim.wo.number = true
vim.o.number = true
vim.o.termguicolors = true
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.wo.signcolumn = 'yes'

