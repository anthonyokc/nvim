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
                -- section_separators = { left = '', right = '' }
                section_separators = { left = '', right = '' }
            },
            sections = {
                lualine_x = {
                    {
                        Harpoon_files
                    },
--                    {
--                        'filename',
--                        path = 3,
--                        shorting_target = 40,
--                    }
                },
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
            },
            extensions = {'fugitive', 'nvim-tree'}
        }
    end
}

