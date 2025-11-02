-- notifications.lua: UI toasts and messages
return {
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            {
                "rcarriga/nvim-notify",
                event = "VeryLazy",
                config = function()
                    ---@diagnostic disable-next-line: missing-fields
                    require("notify").setup({
                        background_colour = "#F5F5F5", -- transparent background
                        render = "wrapped-compact",    -- Options: "default", "minimal", "simple", "compact", "wrapped-compact"
                        stages = "fade_in_slide_out",  -- Animations: "fade_in_slide_out", "slide", "fade", "static"
                        fps = 165,                     -- FPS for animated notifications, set to your monitor's refresh rate
                        timeout = 5000,
                        top_down = true,
                        max_width = 80, -- maximum width of the notification
                        level = 0,      -- minimum log level to display
                        minimum_width = 40,
                        time_formats = {
                            notification = "%T",
                            notification_history = "%FT%T"
                        },
                    })
                end
            }
        },
        opts = {
            messages = {                   -- Noice messages UI
                view = "notify",           -- set view for messages, options: "notify", "mini", "split" or "popup", "virtualtext"
                view_error = "notify",     -- view for errors
                view_warn = "notify",      -- view for warnings
                view_history = "messages", -- view for :messages
            },
            routes = {                     -- Routes let you re-route messages to different views by filtering
                {
                    view = "mini",
                    filter = {
                        event = "msg_show",
                        min_length = 360,
                    },
                }
            }, -- drop notify events
            -- you can enable a preset for easier configuration
            views = {
                mini = {
                    format = { "{cmdline}\n", "{title}", "{level}", "{event} ", "{kind}", "\n{message}" },
                    timeout = 5000, -- 5s before disappearing
                    focusable = true,
                    border = { style = "rounded", },
                    position = {
                        row = -2,     -- -2 sodsfds it is above the statusline
                        col = "100%", -- right aligned
                    },
                    size = {
                        max_height = 200,
                        max_width = 80,
                    }
                },
                cmdline_popup = {
                    position = {
                        row = "50%",
                        col = "50%",
                    },
                    size = {
                        height = "auto",
                        width = 60,
                    },
                    border = {
                        style = "rounded",
                        padding = { 0, 0 },
                    },
                    win_options = {
                        winhighlight = {

                            Normal = "NormalFloat",
                            FloatBorder = "FloatBorder",
                        }
                    },
                },
                popupmenu = {
                    enabled = true,
                    backend = "cmp" -- backend to use to show regular cmdline completions
                },
                hover = {
                    border = {
                        style = "rounded",
                        padding = { 0, 2 },
                    },
                    position = {
                        row = 2,
                        col = 0
                    },
                    win_options = {
                        winhighlight = {
                            Normal = "NormalFloat",
                            FloatBorder = "FloatBorder",
                        }
                    },
                }
            },
            format = {
                level = { -- Format for the message level within messages
                    icons = {
                        error = "",
                        warn  = "",
                        info  = "",
                        debug = "",
                        trace = "✎",
                    },
                    hl_group = {
                        error = "NotifyERRORIcon",
                        warn  = "NotifyWARNIcon",
                        info  = "NotifyINFOIcon",
                        debug = "NotifyDEBUGIcon",
                        trace = "NotifyTRACEIcon",
                    }
                },
                cmdline = {
                    hl_group = "NoiceFormatCmdline",
                },
            },
            lsp = {
                -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
                },
                signature = {
                    enabled = false,
                },
                progress = {
                    enabled = true,
                },
            },
        },
        keys = {
            -- { "<S-Enter>",   function() require("noice").redirect(vim.fn.getcmdline()) end,                 mode = "c",                              desc = "Redirect Cmdline" },
            { "<c-n>",       function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end,  silent = true,                           expr = true,              desc = "Scroll Forward",  mode = { "i", "n", "s" } },
            { "<c-p>",       function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true,                           expr = true,              desc = "Scroll Backward", mode = { "i", "n", "s" } },
        },
        config = function(_, opts)
            require("noice").setup(opts)
            vim.keymap.set("n", "<leader>dn", "<cmd>NoiceDismiss<CR>", { desc = "Dismiss Noice Message" }) -- Dismiss Noice Message
            vim.api.nvim_set_hl(0, "NoiceFormatEvent", { link = "NotifyTRACETitle" })
            vim.api.nvim_set_hl(0, "NoiceFormatKind", { link = "NotifyDEBUGTitle" })
            vim.api.nvim_set_hl(0, "NoiceFormatCmdline", { link = "NotifyTRACETitle" })
        end
    },
}
