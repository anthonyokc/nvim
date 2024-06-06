return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "letieu/harpoon-lualine",
    },
    config = function()
        require('lualine').setup {
            options = {
                icons_enabled = true,
                component_separators = '',
                section_separators = { left = '', right = '' }
            },
            sections = {
                lualine_a = {
                    {
                        'filetype',
                        colored = false,
                        icon_only = true,
                        icon = { align = 'right' }, -- Display filetype icon on the right hand side
                        padding = { left = 1, right = 0 }
                    },
                    {
                        'filename',
                        padding = { left = 0, right = 1 }
                    }
                },
                lualine_b = {
                    'branch', 'diff', 'diagnostics'
                },
                lualine_c = {
                    ''
                },
                lualine_x = {
                    {
                        require("noice").api.status.command.get_hl,
                        cond = require("noice").api.status.command.has,
                    },
                    {
                        Harpoon_files
                    },
                },
                lualine_z = {
                    {
                        function()
                            local line = vim.fn.line('.')
                            local total_lines = vim.fn.line('$')
                            return line .. '/' .. total_lines
                        end,
                        cond = nil,
                        color = nil,
                        padding = 1
                    },
                }
            },
            extensions = {'fugitive', 'nvim-tree'}
        }
    end
}

