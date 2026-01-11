local Utils = require('utils')

local exprnnoremap = Utils.exprnnoremap
local nnoremap = Utils.nnoremap
local vnoremap = Utils.vnoremap
local xnoremap = Utils.xnoremap
local inoremap = Utils.inoremap

local tnoremap = Utils.tnoremap
local nmap = Utils.nmap
local xmap = Utils.xmap

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- disable <leader> from working by itself
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- -- kj to normal mode
inoremap('kj', '<Esc>')

-- -- page up/down with recentering
nnoremap('<C-u>', '<C-u>zz')
nnoremap('<C-d>', '<C-d>zz')
nnoremap('j', 'jzz')
nnoremap('k', 'kzz')

-- -- Run omnifunc, mostly used for autocomplete
-- inoremap('<C-SPACE>', '<C-x><C-o>')

-- -- Save with Ctrl + S
nnoremap('<C-s>', '<cmd>w<CR>')
inoremap('<C-s>', '<cmd>w<CR>')

-- -- Close buffer
-- nnoremap('<C-c>', ':q<CR>')

-- Move around windows (shifted to the right)
nnoremap('<C-h>', '<C-w>h')
nnoremap('<C-j>', '<C-w>j')
nnoremap('<C-k>', '<C-w>k')
nnoremap('<C-l>', '<C-w>l')

-- Open floating command pallete
nnoremap(':', '<cmd>FineCmdline<CR>')

-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', '<cmd>Telescope oldfiles<CR>', { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', '<cmd>Telescope buffers<CR>', { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/',
    [[<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown { winblend = 10, previewer = false })<CR>]],
    { desc = '[/] Fuzzily search in current buffer' }
)
vim.keymap.set('n', '<leader>sf', '<cmd>Telescope find_files<CR>', { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', '<cmd>Telescope help_tags<CR>', { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', '<cmd>Telescope grep_string<CR>', { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', '<cmd>Telescope live_grep<CR>', { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', '<cmd>Telescope diagnostics<CR>', { desc = '[S]earch [D]iagnostics' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Exit terminal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit Terminal Mode' })

-- Lsp Saga keymaps
vim.keymap.set('n', '<leader>ca', ':Lspsaga code_action<CR>', { desc = '[C]ode [A]ction' })
vim.keymap.set('v', '<leader>pd', ':Lspsaga peek_type_definition', { desc = '[P]eek Type [D]efinition' })

vim.keymap.set("i", "<C-CR>", 'copilot#Accept("<CR>")', { expr = true, replace_keycodes = false })

vim.keymap.set('i', '<M-.>', '<Plug>(copilot-next)')
vim.keymap.set('i', '<M-,>', '<Plug>(copilot-previous)')


-- -- Switch buffers (needs nvim-bufferline)
-- nnoremap('<TAB>', ':BufferLineCycleNext<CR>')
-- nnoremap('<S-TAB>', ':BufferLineCyclePrev<CR>')

-- -- Splits
-- nnoremap('<leader>ws', ':split<CR>')
-- nnoremap('<leader>vs', ':vsplit<CR>')

-- -- Populate substitution
-- nnoremap('<leader>s', ':s//g<Left><Left>')
-- nnoremap('<leader>S', ':%s//g<Left><Left>')
-- nnoremap('<leader><C-s>', ':%s//gc<Left><Left><Left>')

-- vnoremap('<leader>s', ':s//g<Left><Left>')
-- vnoremap('<leader><A-s>', ':%s//g<Left><Left>')
-- vnoremap('<leader>S', ':%s//gc<Left><Left><Left>')

-- -- Delete buffer
-- nnoremap('<A-w>', ':bd<CR>')

-- -- Yank to end of line
-- nnoremap('Y', 'y$')

-- -- Paste into selection without overwriting p register
-- xnoremap('<leader>p', '\'_dP')

-- -- Delete without overwriting register
-- nnoremap('<leader>d', '\'_d')
-- vnoremap('<leader>d', '\'_d')

-- -- Copy to system clippboard
-- nnoremap('<leader>y', ''+y')
-- vnoremap('<leader>y', ''+y')

-- -- Paste from system clippboard
-- nnoremap('<leader>P', ''+p')
-- vnoremap('<leader>P', ''+p')

-- -- Clear highlight search
-- nnoremap('<leader>nh', ':nohlsearch<CR>')
-- vnoremap('<leader>nh', ':nohlsearch<CR>')

-- -- Local list
-- nnoremap('<leader>lo', ':lopen<CR>')
-- nnoremap('<leader>lc', ':lclose<CR>')
-- nnoremap('<C-n>', ':lnext<CR>')
-- nnoremap('<C-p>', ':lprev<CR>')

-- -- Quickfix list
-- nnoremap('<leader>co', ':copen<CR>')
-- nnoremap('<leader>cc', ':cclose<CR>')
-- nnoremap('<C-N>', ':cnext<CR>')
-- nnoremap('<C-P>', ':cprev<CR>')

-- -- Open file in default application
-- nnoremap('<leader>xo', '<Cmd> !xdg-open %<CR><CR>')

-- -- Fugitive
-- nnoremap('<leader>G', ':G<CR>')
-- nnoremap('<leader>gl', ':Gclog<CR>')

-- -- Show line diagnostics
-- nnoremap('<leader>i', '<Cmd>lua vim.diagnostic.open_float(0, {scope = 'line'})<CR>')

-- -- Open local diagnostics in local list
-- nnoremap('<leader>I', '<Cmd>lua vim.diagnostic.setloclist()<CR>')

-- -- Open all project diagnostics in quickfix list
-- -- nnoremap('<leader><A-I>', '<Cmd>lua vim.diagnostic.setqflist()<CR>')

-- -- Telescope
-- nnoremap('<leader>o', '<Cmd>Telescope find_files<CR>')
-- nnoremap('<leader>H', '<Cmd>Telescope find_files hidden=true<CR>')
-- nnoremap('<leader>b', '<Cmd>Telescope buffers<CR>')
-- nnoremap('<leader>lg', '<Cmd>Telescope live_grep<CR>')

-- -- File explorer
-- nnoremap('<leader>e', '<Cmd>NvimTreeToggle<CR>')  -- NvimTree
-- -- nnoremap('<leader>e', '<Cmd>RnvimrToggle<CR>')

-- -- EasyAlign
-- -- xmap('ga', '<cmd>EasyAlign')
-- -- nmap('ga', '<cmd>EasyAlign')

-- -- For when everything else fails
-- -- nnoremap('<leader>fml', '<Cmd>CellularAutomaton make_it_rain<CR>')
