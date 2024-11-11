return {
    {
        'maxmx03/fluoromachine.nvim',
        config = function()
            local fm = require 'fluoromachine'

            -- fm.setup {
            --     glow = false,
            --     theme = 'fluoromachine'
            -- }

            fm.setup {
                glow = true,
                theme = 'retrowave',
                colors = function(_, d)
                    return {
                        bg = '#241f31',
                        alt_bg = d('#190920', 20),
                        cyan = '#49eaff',
                        red = '#c01c28',
                        yellow = '#ffe756',
                        orange = '#f38e21',
                        pink = '#dc8add',
                        purple = '#9141ac',
                    }
                end,
            }

            vim.cmd.colorscheme 'fluoromachine'
        end
    },
    {
        'lunarvim/synthwave84.nvim',
        config = function()
            vim.cmd.colorscheme 'synthwave84'
        end
    },
    {
        'navarasu/onedark.nvim',
        priority = 1000,
        config = function()
            vim.cmd.colorscheme 'onedark'
        end,
    },
}
