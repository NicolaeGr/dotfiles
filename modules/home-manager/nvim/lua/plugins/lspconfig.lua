return {
    'lukas-reineke/lsp-format.nvim',
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            { 'williamboman/mason.nvim', config = true },
            'williamboman/mason-lspconfig.nvim',
            'folke/neodev.nvim',
            {
                'j-hui/fidget.nvim',
                opts = {}
            },
            {
                'nvimdev/lspsaga.nvim',
                config = function()
                    require('lspsaga').setup({})
                end
            }
        },
        config = function()
            local on_attach = function(_, bufnr)
                local nmap = function(keys, func, desc)
                    if desc then
                        desc = 'LSP: ' .. desc
                    end

                    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
                end

                nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

                nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
                nmap('gr', '<cmd>Telescope lsp_references<cr>', '[G]oto [R]eferences')
                nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
                nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
                nmap('<leader>ds', '<cmd>Telescope lsp_document_symbols<cr>', '[D]ocument [S]ymbols')
                nmap('<leader>ws', '<cmd>Telescope lsp_dynamic_workspace_symbols<cr>', '[W]orkspace [S]ymbols')

                -- See `:help K` for why this keymap
                nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
                nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

                -- Lesser used LSP functionality
                nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
                nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
                nmap('<leader>wl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, '[W]orkspace [L]ist Folders')

                -- Create a command `:Format` local to the LSP buffer
                vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
                    vim.lsp.buf.format()
                end, { desc = 'Format current buffer with LSP' })
            end


            local servers = {
                -- clangd = {},
                -- gopls = {},
                -- pyright = {},
                -- rust_analyzer = {},
                -- tsserver = {},

                lua_ls = {
                    Lua = {
                        workspace = { checkThirdParty = false },
                        telemetry = { enable = false },
                    },
                },
            }

            require('neodev').setup()

            -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

            -- Ensure the servers above are installed
            local mason_lspconfig = require 'mason-lspconfig'

            mason_lspconfig.setup {
                ensure_installed = vim.tbl_keys(servers),
            }

            mason_lspconfig.setup_handlers {
                function(server_name)
                    require('lspconfig')[server_name].setup {
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = servers[server_name],
                    }
                end,
            }
        end
    },

    {
        'MunifTanjim/prettier.nvim',
        dependencies = {
            {
                'jose-elias-alvarez/null-ls.nvim',
                config = function()
                    local on_attach = function(client, bufnr)
                        if client.supports_method("textDocument/formatting") then
                            vim.keymap.set("n", "<Leader>f", function()
                                vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
                            end, { buffer = bufnr, desc = "[lsp] format" })

                            -- format on save
                            vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
                            vim.api.nvim_create_autocmd(event, {
                                buffer = bufnr,
                                group = group,
                                callback = function()
                                    vim.lsp.buf.format({ bufnr = bufnr, async = async })
                                end,
                                desc = "[lsp] format on save",
                            })
                        end

                        if client.supports_method("textDocument/rangeFormatting") then
                            vim.keymap.set("x", "<Leader>f", function()
                                vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
                            end, { buffer = bufnr, desc = "[lsp] format" })
                        end
                    end
                end
            }
        },
        config = function()
            require('prettier').setup {
                bin = 'prettier',
                filetypes = {
                    filetypes = {
                        "css",
                        "graphql",
                        "html",
                        "javascript",
                        "javascriptreact",
                        "json",
                        "less",
                        "markdown",
                        "scss",
                        "typescript",
                        "typescriptreact",
                        "yaml",
                    },
                },
            }
        end

    },

    'github/copilot.vim',
}
