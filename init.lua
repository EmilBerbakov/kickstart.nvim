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
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrw = 1
-- vim.o.termguicolors = false
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.confirm = true
require('vim._core.ui2').enable({})
local is_windows = vim.loop.os_uname().sysname == 'Windows_NT' or vim.env.WSL_DISTRO_NAME ~= nil
vim.o.cursorline = true
vim.pack.add {
	--without mason-lspconfig + mason-tool-installer, you have to look at each cmd in ~/.local/share/nvim/site/pack/core/opt/nvim-lspconfig/lsp/ for the lsp you want, and make sure you have whatever runs the command installed
	--for example, ts_ls needs typescript-language-server installed, which is done with
	-- ``` npm install -g typescript-language-server typescript ```
	-- For Windows, this path is %localappdata%\nvim-data\site\pack\core\opt\nvim-lspconfig\lsp
	--TODO: - testing
	{ src = 'https://github.com/neovim/nvim-lspconfig' },
	{ src = 'https://github.com/NMAC427/guess-indent.nvim' },
	{ src = 'https://github.com/nvim-mini/mini.nvim' },
	{ src = 'https://github.com/folke/lazydev.nvim' },
	{ src = 'https://github.com/stevearc/conform.nvim' },
}
vim.pack.add { { src = 'https://github.com/f-person/auto-dark-mode.nvim' } }
require('auto-dark-mode').setup({
	update_interval = 1000,
	set_dark_mode = function()
		if vim.o.termguicolors == false
		then
			return
		end
		vim.api.nvim_set_hl(0, "NormalFloat", { ctermbg = "NONE", ctermfg = "NONE", reverse = false })
		vim.api.nvim_set_hl(0, "Pmenu", { ctermbg = "NONE", ctermfg = "NONE", reverse = false })
		vim.api.nvim_set_hl(0, "CursorLine", { ctermbg = 235 })
		vim.api.nvim_set_hl(0, 'Comment', { ctermfg = 14, italic = true })
	end,

	set_light_mode = function()
		if vim.o.termguicolors == false
		then
			return
		end
		vim.api.nvim_set_hl(0, "NormalFloat", { ctermbg = "NONE", ctermfg = "NONE", reverse = false })
		vim.api.nvim_set_hl(0, "Pmenu", { ctermbg = "NONE", ctermfg = "NONE", reverse = false })
		vim.api.nvim_set_hl(0, "CursorLine", { ctermbg = 255 })
		vim.api.nvim_set_hl(0, 'Comment', { ctermfg = 14, italic = true })
	end
})

if is_windows then
	vim.opt.shell = 'pwsh -nologo'

	_G.reload_theme = function()
		local f = io.open(vim.fn.expand('~/AppData/Local/nvim/lua/generated_colors.lua'), 'r')
		if not f then
			vim.notify('Matugen Generated Color Scheme not found', vim.log.levels.ERROR)
			return
		end
		local tab = f:read('*a')
		f:close()

		local load_tab, err = load(tab)
		if err then
			vim.notify('Matugen Generated Color Scheme not found', vim.log.levels.ERROR)
			return
		end
		if load_tab then
			local ok, new_palette = pcall(load_tab)
			if ok and type(new_palette) == 'table' then
				require('mini.base16').setup({ palette = new_palette })
			end
		end
	end

	-- Fallback check on startup if file loading fails
	package.loaded['generated_colors'] = nil
	local ok, new_palette = pcall(require, 'generated_colors')
	if ok then
		require('mini.base16').setup({ palette = new_palette })
	end

	_G.reload_theme()

	_G.watcher = vim.uv.new_fs_event()
	local path = vim.fn.expand('~/AppData/Local/nvim/lua')
	local is_reloading = false

	if _G.watcher then
		_G.watcher:start(path, {}, vim.schedule_wrap(function(err, filename, _)
			if err or not filename then
				vim.notify('Failed to initialize Matugen Theme File Watcher.', vim.log.levels.ERROR)
				return
			end
			if filename == 'generated_colors.lua' and not is_reloading then
				is_reloading = true
				vim.defer_fn(function()
					_G.reload_theme()
					is_reloading = false
				end, 50)
			end
		end))
	else
		vim.notify('Failed to initialize file watcher', vim.log.levels.ERROR)
	end
end
require('mini.extra').setup()
require('mini.pick').setup()
require('mini.pairs').setup()
require('mini.surround').setup()
require('mini.notify').setup()
require('guess-indent').setup({})
local miniclue = require('mini.clue')
miniclue.setup({
	triggers = {
		-- Leader triggers
		{ mode = { 'n', 'x' }, keys = '<Leader>' },

		-- `[` and `]` keys
		{ mode = 'n',          keys = '[' },
		{ mode = 'n',          keys = ']' },

		-- Built-in completion
		{ mode = 'i',          keys = '<C-x>' },

		-- `g` key
		{ mode = { 'n', 'x' }, keys = 'g' },

		-- Marks
		{ mode = { 'n', 'x' }, keys = "'" },
		{ mode = { 'n', 'x' }, keys = '`' },

		-- Registers
		{ mode = { 'n', 'x' }, keys = '"' },
		{ mode = { 'i', 'c' }, keys = '<C-r>' },

		-- Window commands
		{ mode = 'n',          keys = '<C-w>' },


		-- `z` key
		{ mode = { 'n', 'x' }, keys = 'z' },

		-- `s` key
		{ mode = 'n',          keys = 's' }
	},
	window = {
		delay = 0,
		config = {
			width = '50',
		}
	},
	clues = {
		{ mode = 'n', keys = '<leader>s', desc = '[S]earch' },
		{ mode = 'n', keys = '<leader>p', desc = '[P]lugin' },
		{ mode = 'n', keys = '<leader>d', desc = '[D]iagnostics' },
		{ mode = 'n', keys = '<leader>g', desc = '[G]it' },
		miniclue.gen_clues.square_brackets(),
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),
	}
})
local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
	return '%2l:%-2v'
end

require('mini.ai').setup { nlines = 500 }
require('mini.icons').setup()
require('mini.completion').setup()
require('mini.files').setup({
	mappings = {
		go_in = 'L',
		go_in_plus = 'l',
		go_out = 'H',
		go_out_plus = 'h',
		close = '<esc>'
	},
	windows = {
		max_number = 1
	},
})
vim.api.nvim_create_autocmd('User', {
	pattern = 'MiniFilesWindowOpen',
	callback = function() require('mini.clue').enable_buf_triggers() end
})


vim.api.nvim_create_autocmd('User', {
	pattern = 'MiniFilesWindowUpdate',
	callback = function(args)
		vim.wo[args.data.win_id].relativenumber = true
		vim.wo[args.data.win_id].number = true
	end
})

require('lazydev').setup { library = { path = '${3rd}/luv/library', words = { 'vim%.uv' } } }
require('mini.git').setup({
	commands = {
		blame = "blame --no-filename"
	}
})

vim.api.nvim_set_hl(0, "GitBlameHashRoot", { link = "Tag" })
vim.api.nvim_set_hl(0, "GitBlameHash", { link = "Identifier" })
vim.api.nvim_set_hl(0, "GitBlameAuthor", { link = "String" })
vim.api.nvim_set_hl(0, "GitBlameDate", { link = "Comment" })

vim.api.nvim_create_autocmd('User', {
	pattern = 'MiniGitCommandSplit',
	callback = function(e)
		if e.data.git_subcommand ~= 'blame' then
			return
		end
		local win_src = e.data.win_source
		local buf = e.buf
		local win = e.data.win_stdout
		-- Opts
		vim.bo[buf].modifiable = false
		vim.wo[win].wrap = false
		vim.wo[win].cursorline = true
		-- View
		vim.fn.winrestview({ topline = vim.fn.line('w0', win_src) })
		vim.api.nvim_win_set_cursor(0, { vim.fn.line('.', win_src), 0 })
		vim.wo[win].scrollbind, vim.wo[win_src].scrollbind = true, true
		vim.wo[win].cursorbind, vim.wo[win_src].cursorbind = true, true
		-- Vert width
		if e.data.cmd_input.mods:match("vertical") then
			local lines = vim.api.nvim_buf_get_lines(0, 1, -1, false)
			local width = vim.iter(lines):fold(-1, function(acc, ln)
				local stat = string.match(ln, "^%S+ %b()")
				return math.max(acc, vim.fn.strwidth(stat))
			end)
			width = width + vim.fn.getwininfo(win)[1].textoff
			vim.api.nvim_win_set_width(win, width)
		end
		-- Highlight
		vim.fn.matchadd("GitBlameHashRoot", [[^^\w\+]])
		vim.fn.matchadd("GitBlameHash", [[^\w\+]])
		local leftmost = [[^.\{-}\zs]]
		vim.fn.matchadd("GitBlameAuthor", leftmost .. [[(\zs.\{-} \ze\d\{4}-]])
		vim.fn.matchadd("GitBlameDate", leftmost .. [[[0-9-]\{10} [0-9:]\{8} [+-]\d\+]])
	end
})
require('mini.diff').setup()


local servers = { 'ts_ls', 'angularls', 'lua_ls', 'vimdoc_ls', 'vimls', 'csharp_ls', 'cssls', 'pyright' }

for _, server in ipairs(servers) do
	vim.lsp.enable(server)
end

vim.lsp.config.angularls = {
	cmd = {
		'ngserver',
		'--stdio',
		'--tsProbeLocations',
		string.format("%s/node_modules", vim.fs.root(0, 'angular.json')),
		'--ngProbeLocations',
		string.format("%s/node_modules", vim.fs.root(0, 'angular.json')),
	},
	on_attach = function(_, bufnr)
		if not string.find(vim.fn.expand '%t', '.component.') then
			return
		end
		table.insert(MiniClue.config.clues, { mode = 'n', keys = 'grs', desc = '[S]pecial Angular Actions' })
		table.insert(MiniClue.config.clues,
			{ mode = 'n', keys = 'grss', desc = '[S]pecial [S]plitscreen Angular Actions' })
		local map = function(keys, func, desc, mode, silent)
			mode = mode or 'n'
			silent = silent or false
			desc = desc or 'No Description Set'
			vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'Angular: ' .. desc, silent = silent })
		end
		local has_template = vim.fn.filereadable(vim.fn.expand '%<' .. '.html')
		local has_scss = vim.fn.filereadable(vim.fn.expand '%<' .. '.scss')
		if vim.fn.expand '%' ~= vim.fn.expand '%<' .. '.html' then
			-- Goto Template Code
			if has_template == 1 then
				map('grsh', '<CMD>e %<.html <CR>', 'Open [H]TML Template', nil, true)
				map('grssh', '<CMD>vsplit %<.html <CR>', 'Open Component [H]TML Template File',
					nil, true)
			end
		end

		if vim.fn.expand '%' ~= vim.fn.expand '%<' .. '.ts' then
			-- Goto Component Code

			map('grst', '<CMD>e %<.ts <CR>', 'Open [T]ypeScript Component File', nil, true)
			map('grsst', '<CMD>vsplit %<.ts <CR>', 'Open [T]ypeScript Component File', nil,
				true)
		end

		if vim.fn.expand '%' ~= vim.fn.expand '%<' .. '.scss' then
			-- Goto SCSS
			if has_scss == 1 then
				map('grsc', '<CMD>e %<.scss <CR>', 'Open Component S[C]SS file', nil, true)
				map('grssc', '<CMD>vsplit %<.scss <CR>', 'Open Component S[C]SS file', nil, true)
			end
		end
	end,

	filetypes = { 'typescript', 'html', 'typescriptreact', 'htmlangular', 'scss', 'css' },

}

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

local function pack_clean()
	local active_plugins = {}
	local unused_plugins = {}

	for _, p in ipairs(vim.pack.get()) do
		active_plugins[p.spec.name] = p.active
	end
	for _, p in ipairs(vim.pack.get()) do
		if not active_plugins[p.spec.name] then
			table.insert(unused_plugins, p.spec.name)
		end
	end

	if #unused_plugins == 0 then
		print('No unused plugins')
		return
	end

	local choice = vim.fn.confirm('Remove unused plugins?', '&Yes\n&No', 2)
	if choice == 1 then
		vim.pack.del(unused_plugins)
	end
end

MiniPick.registry.pack_list = function()
	MiniPick.start({
		source = {
			name = "Plugin List",
			items = vim.pack.get(),
			show = function(buf_id, items)
				local lines = {}
				for i, item in ipairs(items) do
					table.insert(lines, string.format("%s. %s(%s)", i, item.spec.name, item.spec.src))
				end
				vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
			end,
			choose = function(item)
				local choice = vim.fn.confirm(
					string.format('Perform what action on %s?', item.spec.name),
					'&Update\n&Remove\n&Goto Source\n&Cancel', 4)
				if choice == 1 then
					vim.pack.update({ item.spec.name })
				elseif choice == 2 then
					vim.pack.del({ item.spec.name })
				elseif choice == 3 then
					vim.ui.open(item.spec.src)
				elseif choice == 4 then
					vim.schedule(function()
						MiniPick.builtin.resume()
					end
					)
				end
			end
		}
	})
end

vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

--Package Manager Keys
vim.keymap.set('n', '<leader>pc', pack_clean, { desc = '[P]lugin [C]leanup' })
vim.keymap.set('n', '<leader>pu', vim.pack.update, { desc = '[P]lugin [U]pdate' })
vim.keymap.set('n', '<leader>pl', MiniPick.registry.pack_list, { desc = '[P]lugin [L]ist' })


--Diagnostic Keys
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open [D]iagnostic [Q]uickfix List' })
vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float, { desc = 'Open [D]iagnostic [F]loating Window' })
vim.diagnostic.config {
	severity_sort = true,
	float = { border = 'rounded', source = 'if_many' },
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = vim.g.have_nerd_font and {
		text = {
			[vim.diagnostic.severity.ERROR] = '󰅚 ',
			[vim.diagnostic.severity.WARN] = '󰀪 ',
			[vim.diagnostic.severity.INFO] = '󰋽 ',
			[vim.diagnostic.severity.HINT] = '󰌶 ',
		},
	} or {},
}

--Terminal Keys
vim.keymap.set('n', '<leader>t', '<CMD> split | term<CR>i', { desc = 'Open [T]erminal' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

--Window Movement Keys
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set('n', '<C-q>', '<C-w>q', { desc = 'Close window' })

--Search Keys
vim.keymap.set('n', '<leader>sh', '<CMD>Pick help<CR>', { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', '<CMD>Pick keymaps<CR>', { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', '<CMD>Pick files<CR>', { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sg', '<CMD>Pick grep_live<CR>', { desc = '[S]earch [G]rep (<C-o> to add Glob)' })
vim.keymap.set('n', '<leader>sc', MiniExtra.pickers.colorschemes, { desc = '[S]earch [C]olorschemes' })
vim.keymap.set('n', '<leader>sb', '<CMD>Pick buffers<CR>', { desc = '[S]earch [B]uffers' })

--Git Keys
vim.keymap.set('n', '<leader>gB', '<CMD>vert Git blame -- %<CR>', { desc = '[G]it [B]lame File' })
vim.keymap.set('n', '<leader>gS', ':Git send ', { desc = '[G]it [S]end' })

--LSP keys
vim.keymap.set('n', 'grd', function() MiniExtra.pickers.lsp { scope = 'definition' } end,
	{ desc = '[G]oto [D]efinition' })
vim.keymap.set('n', 'grD', function() MiniExtra.pickers.lsp { scope = 'declaration' } end,
	{ desc = '[G]oto [D]eclaration' })
vim.keymap.set('n', 'gri', function() MiniExtra.pickers.lsp { scope = 'implementation' } end,
	{ desc = '[G]oto [I]mplementation' })
vim.keymap.set('n', 'grr', function()
	MiniExtra.pickers.lsp { scope = 'references' }
end, { desc = '[G]oto [R]eferences' })
vim.keymap.set('n', 'grt', function() MiniExtra.pickers.lsp { scope = 'type_definition' } end,
	{ desc = '[G]oto [T]ype Definition' })
vim.keymap.set('n', 'gO', function() MiniExtra.pickers.lsp { scope = 'document_symbol' } end,
	{ desc = '[G]oto D[o]cument Symbol' })
MiniClue.set_mapping_desc('n', 'gra', '[G]oto Code [A]ctions')
MiniClue.set_mapping_desc('n', 'grn', '[G]oto Re[n]ame')
MiniClue.set_mapping_desc('n', 'grx', 'Code.run()')

--Misc. Keys
vim.keymap.set('n', '<leader>f',
	function() require("conform").format { async = true, lsp_format = "fallback" } end,
	{ desc = '[F]ormat' })
vim.keymap.set('n', '<leader>r', '<CMD>restart<CR>', { desc = '[R]estart' })
vim.keymap.set('n', '<Esc>', '<CMD>nohlsearch<CR>', { desc = 'clear highlights' })
local minifiles_toggle = function()
	local current_file = vim.api.nvim_buf_get_name(0)
	if not MiniFiles.close() then MiniFiles.open(current_file) end
end
vim.keymap.set('n', '-', minifiles_toggle, { desc = 'open parent directory' })
vim.keymap.set('v', '<', '<gv', { desc = 'indent left and reselect' })
vim.keymap.set('v', '>', '>gv', { desc = 'indent right and reselect' })
