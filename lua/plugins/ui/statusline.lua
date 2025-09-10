return {
    "nvim-lualine/lualine.nvim",
    event = "UIEnter",
    dependencies = {
        "letieu/harpoon-lualine",
    },
    config = function()
        -- Status line for R-nvim
        local rstt =
        {
            { "nclientserver not started",        "#aaaaaa" },     -- 1: ftplugin/* sourced, but nclientserver not started yet.
            { "nclientserver started, not ready", "#757755" },     -- 2: nclientserver started, but not ready yet.
            { "nclientserver, ready",             "#lightgreen" }, -- 3: nclientserver is ready.
            { "TCP starting...",                  "#ff8833" },     -- 4: nclientserver started the TCP server
            { "TCP server ready",                 "#lightgreen" }, -- 5: TCP server is ready
            { "R started, nvimcom not loaded",    "#ff8833" },     -- 6: R started, but nvimcom was not loaded yet.
            { "R",                                "#3388ff" },     -- 7: nvimcom is loaded.
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
                        require('config.util').root_dir({
                            mode = "file_dir",
                            truncate = 60,
                            icon = "",
                        }),
                        color = { fg = "#444444" },
                        padding = { right = 0 }
                    },
                    {
                        require('config.util').root_dir({
                            mode = "file_base",
                            truncate = 60,
                            icon = "",
                        }),
                        padding = { left = 0 },
                    },
                },
                lualine_b = {
                    'branch',
                    {
                        "diff",
                        symbols = {
                            added    = " ",
                            modified = " ",
                            removed  = " ",
                        }
                    }
                },
                lualine_c = {
                    {
                        "diagnostics",
                        symbols = {
                            error = " ",
                            warn = " ",
                            info = " ",
                            hint = "󰌵 "
                        },
                    },
                    {
                        '',
                        color = { fg = 'none', bg = 'none' },
                    }
                },
                lualine_x = {
                    ---@diagnostic disable: undefined-field
                    ---@diagnostic disable: undefined-global
                    {
                        function() return require("noice").api.status.command.get() end,
                        cond = function() return package.loaded["noice"] and require("noice").api.status.command.has() end,
                        color = function() return { fg = Snacks.util.color("Statement") } end,
                    },
                    {
                        -- Make sure to set vim.o.showmode = false, otherwise will show "-- INSERT --"
                        function() return require("noice").api.status.mode.get() end,
                        cond = function() return package.loaded["noice"] and require("noice").api.status.mode.has() end,
                        color = function() return { fg = Snacks.util.color("Constant") } end,
                    },
                    {
                        function() return "  " .. require("dap").status() end,
                        cond = function() return package.loaded["dap"] and require("dap").status() ~= "" end,
                        color = function() return { fg = Snacks.util.color("Debug") } end,
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
