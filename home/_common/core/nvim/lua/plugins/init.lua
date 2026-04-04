return {
    { -- Better cmdLine
        'VonHeikemen/fine-cmdline.nvim',
        dependencies = {
            'MunifTanjim/nui.nvim'
        }
    },

    'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

    'andweeb/presence.nvim',  -- Discord presence

    {
        "NotAShelf/direnv.nvim",
        config = function()
            require("direnv").setup({
                bin = "direnv",
                autoload_direnv = true,

                statusline = {
                    enabled = true,
                    icon = "󱚟",
                },

                -- Keyboard mappings
                keybindings = {
                    allow = "<Leader>fda",
                    deny = "<Leader>fdd",
                    reload = "<Leader>fdr",
                    edit = "<Leader>fde",
                },


                notifications = {
                    level = vim.log.levels.INFO,
                    silent_autoload = true,
                },
            })
        end,
    }
}
