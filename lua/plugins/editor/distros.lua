-- distros.lua: a collection of neovim distributions.
-- Each distro includes multiple plugins and configurations all in one.
return {
    {
        'saghen/blink.nvim',
        lazy = true,                     -- all modules handle lazy loading internally
        event = 'InsertEnter',
        build = 'cargo build --release', -- for delimiters
        opts = {
            chartoggle = { enabled = true },
        },
        keys = {
            -- chartoggle
            {
                ',',
                function()
                    require('blink.chartoggle').toggle_char_eol(',')
                end,
                mode = { 'n', 'v' },
                desc = 'Toggle , at eol',
            },
        },
    },
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            -- enabled modules
            bigfile = { enabled = true },
            explorer = {
                enabled = true,
                replace_netrw = true, -- Replace netrw with the snacks explorer
            },
            words = { enabled = true },
            gitbrowse = { enabled = true },
            image = { enabled = true },
            picker = {
                enabled = true,
                defaults = { hidden = true, ignored = true },
                sources = {
                    explorer = {
                        ignored = true,
                        hidden = true, -- Show hidden files by default
                        layout = { preset = "sidebar", preview = false },
                    },
                },
            },
            -- diasbled modules
            dashboard = { enabled = false },
            indent = { enabled = false },
            input = { enabled = false },
            notifier = { enabled = false },
            quickfile = { enabled = false },
            scope = { enabled = false },
            scroll = { enabled = false },
            statuscolumn = { enabled = false },
        },
        keys = {
            ---@diagnostic disable: undefined-global
            { "<leader>e",  function() Snacks.explorer() end,             desc = "File Explorer" },
            { "<leader>gB", function() Snacks.gitbrowse() end,            desc = "Git Browse",          mode = { "n", "v" } },
            { "<leader>gg", function() Snacks.lazygit() end,              desc = "Lazygit" },
        },
    }
}
