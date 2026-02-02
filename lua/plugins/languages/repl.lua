return {
    "hkupty/iron.nvim",
    ft = {
        "nix",
        "ruby",
        "python",
        "lua",
        "javascript",
        "typescript",
        "sh",
        "zsh",
    },
    config = function()
        local iron = require("iron.core")
        local view = require("iron.view")
        local common = require("iron.fts.common")
        iron.setup({
            config = {
                repl_definition = {
                    nix = {
                        command = { "nix", "repl" },
                    },
                    ruby = {
                        command = { "pry" },
                    },
                    typescript = {
                        command = { "deno" },
                    },
                    javascript = {
                        command = { "deno" },
                    },
                    sh = {
                        command = { "bash", "--norc" },
                        format = common.bracketed_paste(),
                    }
                },
                repl_open_cmd = view.split.vertical.botright(),
            },
            highlight = {
                italic = true,
            },
            ignore_blank_lines = true,
            -- Iron doesn't set keymaps by default anymore.
            -- You can set them here or manually add keymaps to the functions in iron.core
            keymaps = {
                toggle_repl = "<space>rr", -- toggles the repl open and closed.
                -- If repl_open_cmd is a table as above, then the following keymaps are
                -- available
                -- toggle_repl_with_cmd_1 = "<space>rv",
                -- toggle_repl_with_cmd_2 = "<space>rh",
                restart_repl = "<space>rR", -- calls `IronRestart` to restart the repl
                send_motion = "<space>sc",
                visual_send = "<space>sc",
                send_file = "<space><enter>",
                send_line = "<enter>",
                send_paragraph = "<space>sp",
                send_until_cursor = "<space>su",
                send_mark = "<space>sm",
                send_code_block = "<space>sb",
                send_code_block_and_move = "<space>sn",
                mark_motion = "<space>mc",
                mark_visual = "<space>mc",
                remove_mark = "<space>md",
                cr = "<space>s<cr>",
                interrupt = "<space>s<space>",
                exit = "<space>sq",
                clear = "<space>cl",
            },
        })
        -- Remaps
        vim.keymap.set("n", "<enter>", function()
            iron.send(nil, string.format("%s\n", vim.fn.getline(".")))
            vim.cmd("normal! j")
        end, { desc = "Send line to REPL and move down" })
    end,
}
