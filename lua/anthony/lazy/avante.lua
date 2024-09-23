return {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false,
    config = function()
        require("avante").setup({
            provider = "claude",
            auto_suggestions_provider = "claude",
            hints = { enabled = false },
            behaviour = {
                auto_suggestions = true,
            },
            mappings = {
                --- @class AvanteConflictMappings
                diff = {
                    ours = "co",
                    theirs = "ct",
                    all_theirs = "ca",
                    both = "cb",
                    cursor = "cc",
                    next = "]x",
                    prev = "[x",
                },
                suggestion = {
                    accept = "<C-j>",
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<C-]>",
                },
                jump = {
                    next = "]]",
                    prev = "[[",
                },
                submit = {
                    normal = "<CR>",
                    insert = "<C-s>",
                },
                sidebar = {
                    switch_windows = "<Tab>",
                    reverse_switch_windows = "<S-Tab>",
                },
            },
        })

        -- local Utils = require("avante.utils")
        --
        -- Utils.safe_keymap_set('i', '<M-]>', function()
        --     local ctx = self:ctx()
        --     if #ctx.suggestions == 0 then return end
        --     ctx.current_suggestion_idx = (ctx.current_suggestion_idx % #ctx.suggestions) + 1
        --     self:show()
        -- end, {
        --     desc = "avante: next suggestion",
        --     replace_keycodes = false
        -- })
        --
        -- Utils.safe_keymap_set('i', '<M-[>', function()
        --     local ctx = self:ctx()
        --     if #ctx.suggestions == 0 then return end
        --     ctx.current_suggestion_idx = ((ctx.current_suggestion_idx - 2 + #ctx.suggestions) % #ctx.suggestions) + 1
        --     self:show()
        -- end, {
        --     desc = "avante: previous suggestion",
        --     replace_keycodes = false
        -- })
    end,
    opts = {
        -- add any opts here
    },
    dependencies = {
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        --- The below dependencies are optional,
        "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
        "zbirenbaum/copilot.lua", -- for providers='copilot'
        {
            -- support for image pasting
            "HakonHarnes/img-clip.nvim",
            event = "VeryLazy",
            opts = {
                -- recommended settings
                default = {
                    embed_image_as_base64 = false,
                    prompt_for_file_name = false,
                    drag_and_drop = {
                        insert_mode = true,
                    },
                },
            },
        },
        {
            -- Make sure to setup it properly if you have lazy=true
            'MeanderingProgrammer/render-markdown.nvim',
            opts = {
                file_types = { "markdown", "Avante" },
            },
            ft = { "markdown", "Avante" },
        },
    },
}
