-- Visual
vim.o.conceallevel         = 0 -- Don't hide quotes in markdown
vim.o.cmdheight            = 1
vim.o.pumheight            = 10
vim.o.showmode             = false
vim.o.termguicolors        = true -- Use true colors, required for some plugins
-- vim.o.ls                 = 0                         -- Doesn't seem to work
-- vim.o.ch                 = 0                         -- Creates a bug with output messages not appearing correctly
vim.wo.number              = true
vim.wo.relativenumber      = true
vim.wo.signcolumn          = 'yes'
vim.wo.cursorline          = true

-- Behavior
vim.o.hlsearch             = false
vim.o.ignorecase           = true -- Ignore case when using lowercase in search
vim.o.smartcase            = true -- But don't ignore it when using upper case
vim.o.smarttab             = true
vim.o.smartindent          = true
vim.o.expandtab            = true -- Convert tabs to spaces.
vim.o.tabstop              = 2
vim.o.softtabstop          = 2
vim.o.shiftwidth           = 2
vim.o.splitbelow           = true
vim.o.splitright           = true
vim.o.scrolloff            = 12 -- Minimum offset in lines to screen borders
vim.o.sidescrolloff        = 8
vim.o.mouse                = 'a'
vim.o.clipboard            = 'unnamedplus'

-- Vim specific
vim.o.hidden               = true  -- Do not save when switching buffers
vim.o.fileencoding         = 'utf-8'
vim.o.spell                = false -- As of v0.8.0 it only checks comments
vim.o.spelllang            = 'en_us'
vim.o.completeopt          = 'menuone,noinsert,noselect'
vim.o.wildmode             = 'longest,full' -- Display auto-complete in Command Mode
vim.o.updatetime           = 300            -- Delay until write to Swap and HoldCommand event
vim.g.do_file_type_lua     = 1

vim.o.breakindent          = true -- Enable break indent
vim.o.undofile             = true -- Save undo history

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase           = true
vim.o.smartcase            = true

-- Keep signcolumn on by default
vim.wo.signcolumn          = 'yes'

-- Decrease update time
vim.o.updatetime           = 250
vim.o.timeout              = true
vim.o.timeoutlen           = 300

-- Disable unused providers
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Disable inline error messages
vim.diagnostic.config {
  virtual_text = false,
  underline = false,
  signs = true, -- Keep gutter signs
}

-- Copilot settings
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true

vim.g.copilot_filetypes = {
  ["*"] = true,
}

vim.cmd.colorscheme 'catppuccin-mocha'

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
