vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = 'yes'
vim.o.winborder = 'rounded'
vim.g.have_nerd_font = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.o.clipboard = 'unnamedplus'
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.confirm = true
local is_windows = vim.loop.os_uname().sysname == 'Windows_NT' or vim.env.WSL_DISTRO_NAME ~= nil

vim.pack.add {
	--without mason-lspconfig + mason-tool-installer, you have to look at each cmd in ~/.local/share/nvim/site/pack/core/opt/nvim-lspconfig/lsp/ for the lsp you want, and make sure you have whatever runs the command installed
	--for example, ts_ls needs typescript-language-server installed, which is done with
	-- ``` npm install -g typescript-language-server typescript ```
	{ src = 'https://github.com/neovim/nvim-lspconfig' },
	{ src = 'https://github.com/NMAC427/guess-indent.nvim' },
	{ src = 'https://github.com/folke/which-key.nvim' },
	{ src = 'https://github.com/nvim-mini/mini.nvim' },
	{ src = 'https://github.com/stevearc/oil.nvim' },
	--when updating, need to cd ~/.local/share/nvim/site/pack/core/opt/blink.cmp, and then cargo build --release
	{ src = 'https://github.com/saghen/blink.cmp' },
	{ src = 'https://github.com/lewis6991/gitsigns.nvim' },
	{ src = 'https://github.com/folke/lazydev.nvim' },
	{ src = 'https://github.com/stevearc/conform.nvim' }
}
if not is_windows then
	vim.pack.add { { src = 'https://github.com/shaunsingh/nord.nvim' } }
	vim.g.nord_disable_background = true
	vim.cmd.colorscheme 'nord'
end
require('mini.pick').setup()
require('mini.pairs').setup()
require('mini.surround').setup()
local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
	return '%2l:%-2v'
end

require('mini.ai').setup { nlines = 500 }
require('mini.icons').setup()
require('oil').setup { view_options = { show_hidden = true } }
require('blink.cmp').setup { fuzzy = { implementation = 'prefer_rust' }, completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } } }
require('gitsigns').setup {
	signs = {
		add = { text = '+' },
		change = { text = '~' },
		delete = { text = '_' },
		topdelete = { text = '‾' },
		changedelete = { text = '~' },
	},
}
require('which-key').setup { spec = { { '<leader>s', group = '[S]earch' }, { '<leader>t', group = '[T]oggle' }, { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } }, { '<leader>b', group = '[B]uffer' }, { '<leader>d', group = '[D]iagnostics' } }, preset = 'helix' }

require('lazydev').setup { library = { path = '${3rd}/luv/library', words = { 'vim%.uv' } } }

local servers = { 'ts_ls', 'angularls', 'lua_ls', 'vimdoc_ls', 'vimls' }

for _, server in ipairs(servers) do
	vim.lsp.enable(server)
end

require('conform').setup({
	notify_on_error = false,
	format_on_save = function(bufnr)
		local disable_filetypes = { c = true, cpp = true }
		if disable_filetypes[vim.bo[bufnr].filetype] then
			return nil
		else
			return {
				timeout_ms = 500,
				lsp_format = 'fallback'
			}
		end
	end
})


vim.keymap.set('n', '<Esc>', '<CMD>nohlsearch<CR>', { desc = 'clear highlights' })
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'open parent directory' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open [D]iagnostic [Q]uickfix List' })
vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float, { desc = 'Open [D]iagnostic [F]loating Window' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<C-q>', '<C-w>q', { desc = 'Close window' })

vim.keymap.set('n', '<leader>sh', '<CMD>Pick help<CR>', { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', '<CMD>Pick keymaps<CR>', { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', '<CMD>Pick files<CR>', { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sg', '<CMD>Pick grep_live<CR>', { desc = '[S]earch [G]rep' })

vim.keymap.set('n', '<leader>sb', '<CMD>Pick buffers<CR>', { desc = '[S]earch [B]uffers' })
vim.keymap.set('n', '<leader>bf',
	function() require("conform").format { async = true, lsp_format = "fallback" } end,
	{ desc = '[B]uffer [F]ormat' })

vim.keymap.set('n', '<leader>r', '<CMD>restart<CR>', { desc = '[R]estart' })
