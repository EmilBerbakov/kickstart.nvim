vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = 'yes'
vim.o.winborder = 'rounded'
vim.o.pumborder = 'rounded'
vim.o.pumheight = 5
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
vim.o.cmdheight = 0
vim.o.termguicolors = true
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.inccommand = 'split'
vim.o.confirm = true
vim.o.laststatus = 3
vim.o.autocomplete = true
vim.opt.shortmess:append { c = true }
vim.opt.completeopt = 'menu,menuone,fuzzy,noinsert,noselect'
require('vim._core.ui2').enable()
local is_windows = vim.loop.os_uname().sysname == 'Windows_NT'
local is_nightly = vim.version().minor > 12
vim.o.cursorline = true
vim.pack.add {
	--without mason-lspconfig + mason-tool-installer, you have to look at each cmd in ~/.local/share/nvim/site/pack/core/opt/nvim-lspconfig/lsp/ for the lsp you want, and make sure you have whatever runs the command installed
	--for example, ts_ls needs typescript-language-server installed, which is done with
	-- ``` npm install -g typescript-language-server typescript ```
	-- For Windows, this path is %localappdata%\nvim-data\site\pack\core\opt\nvim-lspconfig\lsp
	{ src = 'https://github.com/neovim/nvim-lspconfig' },
	{ src = 'https://github.com/nvim-mini/mini.nvim' },
	{ src = 'https://github.com/folke/lazydev.nvim' },
	{ src = 'https://github.com/stevearc/conform.nvim' },
}

vim.cmd.packadd('nvim.undotree')
require('mini.icons').setup()

vim.api.nvim_create_autocmd('FileType', {
	pattern = '*',
	desc = 'Disable auto-commenting newlines',
	callback = function() vim.opt_local.formatoptions = 'jql' end
})

if is_windows then
	vim.opt.shell = 'pwsh -nologo -NoProfile'
	vim.opt.shellcmdflag = '-ExecutionPolicy RemoteSigned -command'
	vim.opt.shellxquote = ''
end

if is_nightly then
	vim.g.loaded_netrwPlugin = 1
	vim.g.loaded_netrw = 1
end
if vim.o.termguicolors then
	_G.reload_theme = function()
		package.loaded['generated_colors'] = nil
		local f = require('generated_colors')
		if not f then
			vim.notify('Matugen Generated Color Scheme not found', vim.log.levels.ERROR)
			return
		end
		require('mini.base16').setup({ palette = f })
		vim.g.colors_name = 'generated_colors'
		local hls = { 'Normal',
			'LineNr', 'LineNrAbove', 'LineNrBelow', 'MiniDiffSignAdd',
			'MiniDiffSignChange', 'MiniDiffSignDelete',
			--TODO - figure out why clearing bg is making just the diagnostic hls lose their fg colors
			-- 'DiagnosticSignOk', 'DiagnosticSignHint', 'DiagnosticSignInfo',
			-- 'DiagnosticSignWarn', 'DiagnosticSignError', 'SignColumn', 'FoldColumn', 'CursorLineSign',
			-- 'CursorLineFold', 'CursorLineNr',
		}
		for _, hl in ipairs(hls) do
			-- local colors = vim.api.nvim_get_hl(0, { name = hl })
			-- vim.api.nvim_set_hl(0, hl, { bg = 'NONE', fg = colors.fg })
			vim.api.nvim_set_hl(0, hl, { bg = 'NONE' })
		end
	end

	_G.reload_theme()

	_G.watcher = vim.uv.new_fs_event()
	local path = vim.fn.stdpath('config') .. '/lua'
	local is_reloading = false

	if _G.watcher then
		_G.watcher:start(path, {}, vim.schedule_wrap(function(err, filename, _)
			if err or not filename then
				vim.notify('Failed to initialize Matugen Theme File Watcher.',
					vim.log.levels.ERROR)
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
		{ mode = 'n',          keys = 's' },
		-- visual mode mini.ai keys
		{ mode = 'v',          keys = 'a' },
		{ mode = 'v',          keys = 'i' }
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

require('mini.ai').setup {
	nlines = 500,
	mappings = {
		around_next = 'aa',
		inside_next = 'ii'
	} }
-- require('mini.files').setup({
-- 	mappings = {
-- 		go_in = 'L',
-- 		go_in_plus = 'l',
-- 		go_out = 'H',
-- 		go_out_plus = 'h',
-- 		close = '<esc>'
-- 	},
-- 	windows = {
-- 		max_number = 1
-- 	},
-- })
-- vim.api.nvim_create_autocmd('User', {
-- 	pattern = 'MiniFilesWindowOpen',
-- 	callback = function() require('mini.clue').enable_buf_triggers() end
-- })


-- vim.api.nvim_create_autocmd('User', {
-- 	pattern = 'MiniFilesWindowUpdate',
-- 	callback = function(args)
-- 		vim.wo[args.data.win_id].relativenumber = true
-- 		vim.wo[args.data.win_id].number = true
-- 	end
-- })

require('lazydev').setup { library = { path = '${3rd}/luv/library', words = { 'vim%.uv' } } }
require('mini.git').setup()

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


local servers = { 'ts_ls', 'angularls', 'lua_ls', 'vimdoc_ls', 'vimls', 'csharp_ls', 'cssls', 'basedpyright', 'yamlls' }

for _, server in ipairs(servers) do
	vim.lsp.enable(server)
end


vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('lsp_completion', { clear = true }),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		if client then
			if client:supports_method('textDocument/completion') then
				vim.lsp.completion.enable(true, client.id, args.buf, {
					autotrigger = true
				})
			end
		end
		if client and client:supports_method('textDocument/formatting') then
			vim.api.nvim_create_autocmd('BufWritePre', {
				buffer = args.buf,
				callback = function()
					vim.lsp.buf.format({ id = client.id })
				end
			})
		end
	end
})

vim.lsp.config('angularls', {
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

})

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

local hls = { 'TextYankPost' }
if is_nightly then table.insert(hls, 'TextPutPost') end
local hlfs = is_nightly and vim.hl.hl_op or vim.hl.on_yank

vim.api.nvim_create_autocmd(hls, {
	desc = 'Highlight when yanking (copying) text',
	group = vim.api.nvim_create_augroup('highlight-cmd', { clear = true }),
	callback = function() hlfs() end
})

--Package Manager Keys
vim.keymap.set('n', '<leader>pc', pack_clean, { desc = '[P]lugin [C]leanup' })
vim.keymap.set('n', '<leader>pu', vim.pack.update, { desc = '[P]lugin [U]pdate' })
vim.keymap.set('n', '<leader>pl', MiniPick.registry.pack_list, { desc = '[P]lugin [L]ist' })

--Diagnostics keys
vim.keymap.set('n', '<leader>dl', function() MiniExtra.pickers.diagnostic({ scope = 'current' }) end,
	{ desc = '[D]iagnostics [L]ist (buffer)' })
vim.keymap.set('n', '<leader>dL', function() MiniExtra.pickers.diagnostic() end,
	{ desc = '[D]iagnostics [L]ist (cwd)' })
vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float, { desc = '[D]iagnostics [F]loating Window' })
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
vim.keymap.set('n', '<tab>', '<cmd>tabn<cr>', { desc = 'Next tab' })
vim.keymap.set('n', '<S-Tab>', '<cmd>tabp<cr>', { desc = 'Previous tab' })

--Search Keys
vim.keymap.set('n', '<leader>sh', '<CMD>Pick help<CR>', { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', '<CMD>Pick keymaps<CR>', { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', '<CMD>Pick files<CR>', { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sg', '<CMD>Pick grep_live<CR>', { desc = '[S]earch [G]rep (<C-o> to add Glob)' })
vim.keymap.set('n', '<leader>sc', MiniExtra.pickers.colorschemes, { desc = '[S]earch [C]olorschemes' })
local wipeout_cur = function()
	vim.api.nvim_buf_delete(MiniPick.get_picker_matches().current.bufnr, {})
end
local buffer_mappings = { wipeout = { char = '<C-d>', func = wipeout_cur } }
vim.keymap.set('n', '<leader>sb', function() MiniPick.builtin.buffers(nil, { mappings = buffer_mappings }) end,
	{ desc = '[S]earch [B]uffers' })
vim.keymap.set('n', '<leader>su', '<CMD>Undotree<CR>', { desc = '[S]earch [U]ndotree' })

--Git Keys
vim.keymap.set('n', '<leader>gB', '<CMD>vert Git blame -s %<CR>', { desc = '[G]it [B]lame File' })
vim.keymap.set('n', '<leader>gS', ':Git send ', { desc = '[G]it [S]end (No quotes; " "= "\\ ")' })
vim.keymap.set('n', '<leader>gb', '<cmd>Pick git_branches<CR>', { desc = '[G]it [B]ranches' })
vim.keymap.set('n', '<leader>gc', '<cmd>Pick git_commits path="%"<cr>', { desc = '[G]it [C]ommits (buffer)' })
vim.keymap.set('n', '<leader>gC', '<cmd>Pick git_commits<cr>', { desc = '[G]it [C]ommits (cwd)' })

--LSP keys
vim.keymap.set('n', 'grd', '<cmd>Pick lsp scope="definition"<cr>', { desc = '[G]oto [D]efinition' })
vim.keymap.set('n', 'grD', '<cmd>Pick lsp scope="declaration"<cr>', { desc = '[G]oto [D]eclaration' })
vim.keymap.set('n', 'gri', '<cmd>Pick lsp scope="implementation"<cr>', { desc = '[G]oto [I]mplementation' })
vim.keymap.set('n', 'grr', '<cmd>Pick lsp scope="references"<cr>', { desc = '[G]oto [R]eferences' })
vim.keymap.set('n', 'grt', '<cmd>Pick lsp scope="type_definition"<cr>', { desc = '[G]oto [T]ype Definition' })
vim.keymap.set('n', 'gO', '<cmd>Pick lsp scope="document_symbol"<cr>', { desc = '[G]oto D[o]cument Symbol' })

MiniClue.set_mapping_desc('n', 'gra', '[G]oto Code [A]ctions')
MiniClue.set_mapping_desc('n', 'grn', '[G]oto Re[n]ame')
MiniClue.set_mapping_desc('n', 'grx', 'Code.run()')
-- TODO - I like this. Maybe I can replace mini.pick with windows that search instead
-- There would have to be a debounce of some kind that would
local function test()
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true,
		{
			relative = 'editor',
			row = 0,
			col = 0,
			width = 30,
			height = 1,
			style = "minimal",
			title = "test",
			border =
			"rounded"
		})
	vim.api.nvim_set_current_win(win)
	vim.cmd('startinsert')
end
--Misc. Keys
-- vim.keymap.set('n', '<leader>l', test)
vim.keymap.set('n', '<leader>f',
	function() require("conform").format { async = true, lsp_format = "fallback" } end,
	{ desc = '[F]ormat' })
vim.keymap.set('n', '<leader>f', vim.lsp.buf.format, { desc = '[F]ormat buffer' })
vim.keymap.set('n', '<leader>r', '<CMD>restart<CR>', { desc = '[R]estart' })
vim.keymap.set('n', '<Esc>', '<CMD>nohlsearch<CR>', { desc = 'clear highlights' })
-- local minifiles_toggle = function()
-- 	local current_file = vim.api.nvim_buf_get_name(0)
-- 	if not MiniFiles.close() then MiniFiles.open(current_file) end
-- end
-- vim.keymap.set('n', '-', minifiles_toggle, { desc = 'open parent directory' })
vim.keymap.set('n', '<leader>e', is_nightly and '<cmd>edit %:p:h<cr>' or '<cmd>20Lexplore %:p:h<cr>',
	{ desc = 'Open Directory (parent)' })
vim.keymap.set('n', '<leader>E', is_nightly and '<cmd>edit .<CR>' or '<cmd>20Lexplore<cr>',
	{ desc = 'Open Directory (cwd)' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'move up half a page and center cursor on screen' })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'move down half a page and center cursor on screen' })
vim.keymap.set('v', '<', '<gv', { desc = 'indent left and reselect' })
vim.keymap.set('v', '>', '>gv', { desc = 'indent right and reselect' })
