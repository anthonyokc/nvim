return {
    "yetone/avante.nvim",
    cmd = { "AvanteToggle", "AvanteChat", "AvanteChatNew", "AvanteAsk", "AvanteEdit", "AvanteBuild" },
    version = false,
    dependencies = {
        -- required dependencies
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        -- Optional dependencies
        "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
        -- {
        --     -- support for image pasting
        --     "HakonHarnes/img-clip.nvim",
        --     event = "VeryLazy",
        --     opts = {
        --         -- recommended settings
        --         default = {
        --             embed_image_as_base64 = false,
        --             prompt_for_file_name = false,
        --             drag_and_drop = {
        --                 insert_mode = true,
        --             },
        --         },
        --     },
        -- },
    },
    init = function()
        vim.keymap.set("n", "<leader>aa", "<cmd>AvanteToggle<cr>", { desc = "Avante: toggle sidebar" })
        vim.keymap.set("n", "<leader>ac", "<cmd>AvanteChat<cr>", { desc = "Avante: chat" })
        vim.keymap.set("n", "<leader>ae", "<cmd>AvanteEdit<cr>", { desc = "Avante: edit with AI" })
    end,
    opts = {
        -- add any opts here
    },
    config = function()
        require("avante").setup({
            provider = "openai", -- Required, default provider for Avante
            providers = {
                openai = {
                    model = "gpt-5", -- or "gpt-5-mini" for lower latency
                    endpoint = "https://api.openai.com/v1",
                    timeout = 60000, -- reasoning models benefit from a higher timeout
                    extra_request_body = {
                        temperature = 1, -- no temp for gpt-5
                        reasoning_effort = "minimal", -- speed > long chain-of-thought
                        verbosity = "low", -- concise final answers
                        max_completion_tokens = 8192, -- room for reasoning + output
                    },
                }
            },
            auto_suggestions_provider = "claude",
            cursor_applying_provider = nil, -- The provider used in the applying phase of Cursor Planning Mode, defaults to nil, when nil uses Config.provider as the provider for the applying phase
            dual_boost = {
                enabled = false,
                first_provider = "openai",
                second_provider = "claude",
                prompt =
                "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
                timeout = 60000, -- Timeout in milliseconds
            },
            hints = { enabled = false },
            behaviour = {
                auto_suggestions = false,
                enable_cursor_planning_mode = false, -- Whether to enable Cursor Planning Mode. Default to false.
                enable_claude_text_editor_tool_mode = true,
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
                -- suggestion = {
                --     accept = "<C-j>",
                --     next = "<M-]>",
                --     prev = "<M-[>",
                --     dismiss = "<C-]>",
                -- },
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

        -- -- Example of custom keymaps for cycling through suggestions
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
}
