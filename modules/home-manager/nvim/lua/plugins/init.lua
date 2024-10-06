return {
    -- Improved File Types
    "nathom/filetype.nvim",

    -- PostCSS syntax highlighting
    'stephenway/postcss.vim',

    -- Git related plugins
    'tpope/vim-fugitive',
    'tpope/vim-rhubarb',

    -- Detect tabstop and shiftwidth automatically
    'tpope/vim-sleuth',

    'andweeb/presence.nvim',

    -- 'leafOfTree/vim-svelte-plugin',


    'vala-lang/vala.vim',

    'othree/html5.vim',
    'pangloss/vim-javascript',
    'evanleck/vim-svelte',


    'leafgarland/typescript-vim',

    -- Better cmdLine
    {
        'VonHeikemen/fine-cmdline.nvim',
        dependencies = {
            'MunifTanjim/nui.nvim'
        }
    },
    {
        -- Autocompletion
        'hrsh7th/nvim-cmp',
        dependencies = {
            'hrsh7th/cmp-nvim-lsp',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'rafamadriz/friendly-snippets'
        },
    },

    -- Useful plugin to show you pending keybinds.
    {
        'folke/which-key.nvim',
        opts = {}
    },
    {
        -- Adds git releated signs to the gutter, as well as utilities for managing changes
        'lewis6991/gitsigns.nvim',
        opts = {
            -- See `:help gitsigns.txt`
            signs = {
                add = { text = '+' },
                change = { text = '~' },
                delete = { text = '_' },
                topdelete = { text = '‾' },
                changedelete = { text = '~' },
            },
        },
    },
    {
        -- Set lualine as statusline
        'nvim-lualine/lualine.nvim',
        -- See `:help lualine.txt`
        opts = {
            options = {
                icons_enabled = false,
                theme = 'onedark',
                component_separators = '|',
                section_separators = '',
            },
        },
    },
    {
        'lukas-reineke/indent-blankline.nvim',
        main = "ibl",
        opts = {
            indent = { char = '┊' },
        },
    },

    -- 'gc' to comment visual regions/lines
    {
        'numToStr/Comment.nvim',
        opts = {}
    },
    {
        'barrett-ruth/live-server.nvim',
        build = 'yarn global add live-server',
        config = function()
            require('live-server').setup {
                args = { '--port=7000', '--browser=org.mozilla.firefox' }
            }
        end
    }
}
