return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "letieu/harpoon-lualine",
    },
    config = function()
        -- Status line for R-nvim
        local rstt =
        {
            { "-", "#aaaaaa" }, -- 1: ftplugin/* sourced, but nclientserver not started yet.
            { "S", "#757755" }, -- 2: nclientserver started, but not ready yet.
            { "S", "#117711" }, -- 3: nclientserver is ready.
            { "S", "#ff8833" }, -- 4: nclientserver started the TCP server
            { "S", "#3388ff" }, -- 5: TCP server is ready
            { "R", "#ff8833" }, -- 6: R started, but nvimcom was not loaded yet.
            { "R", "#3388ff" }, -- 7: nvimcom is loaded.
        }

        local rstatus = function()
            if not vim.g.R_Nvim_status or vim.g.R_Nvim_status == 0 then
                -- No R file type (R, Quarto, Rmd, Rhelp) opened yet
                return ""
            end
            return rstt[vim.g.R_Nvim_status][1]
        end

        local rsttcolor = function()
            if not vim.g.R_Nvim_status or vim.g.R_Nvim_status == 0 then
                -- No R file type (R, Quarto, Rmd, Rhelp) opened yet
                return { fg = "#000000" }
            end
            return { fg = rstt[vim.g.R_Nvim_status][2] }
        end

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
                lualine_y = {
                    {
                        rstatus,
                        color = rsttcolor
                    }
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
            extensions = { 'fugitive', 'nvim-tree' }
        }
    end
}
