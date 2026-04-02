return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
        local wk = require("which-key")
        wk.add({
            -- Case conversion commands
            { "su",          desc = "Convert to lowercase" },
            { "sU",          desc = "Convert to uppercase" },
            { "s~",          desc = "Toggle case" },
            { "gu",          desc = "Convert to lowercase (with motion)" },
            { "gU",          desc = "Convert to uppercase (with motion)" },
            { "g~",          desc = "Toggle case (with motion)" },

            -- File explorer and navigation
            { "<leader>p",   group = "File Explorer" },
            { "<leader>pv",  desc = "Open file explorer" },
            { "<leader>vpp", desc = "Edit packer.lua" },

            { "<leader>l",   group = "Lists" },
            { "<leader>ls",  desc = "List buffers" },
            { "<leader>lm",  desc = "List modified buffers" },

            -- Copy and paste operations
            { "<leader>y",   desc = "Copy to system clipboard" },
            { "<leader>Y",   desc = "Copy line to system clipboard" },
            { "<leader>yay", desc = "Copy whole file to system clipboard" },

            -- Search and replace
            { "<leader>s",  desc = "Search and replace current word" },
            { "<leader>rh",  desc = "Convert read.csv to read_csv with here()" },
            { "<leader>#",   desc = "Convert top line comments to inline" },

            -- LSP and diagnostics
            { "<leader>v",   group = "LSP" },
            { "<leader>vws", desc = "Workspace symbols" },
            { "<leader>vd",  desc = "Open diagnostic float" },
            { "<leader>vca", desc = "Code actions" },
            { "<leader>vrr", desc = "References" },
            { "<leader>F",   desc = "Format buffer" },

            -- Quickfix and location list
            { "<leader>n",   desc = "Next location list item" },
            { "<leader>b",   desc = "Previous location list item" },

            -- Terminal operations
            { "<leader>t",   group = "Terminal" },
            { "<leader>tt",  desc = "Toggle terminal" },
            { "<leader>ht",  desc = "Toggle terminal visibility" },
            { "<leader>'",   desc = "Switch to terminal" },

            -- Window management
            { "<leader>j",   desc = "Toggle window size to 50%" },

            -- Comments
            { "<leader>C",   desc = "Toggle comment", cond = function() return vim.tbl_contains({ "r", "rmd", "quarto" }, vim.bo.filetype) end },
            { "<leader>td",  desc = "Toggle TODO on current line" },
            { "<leader>tD",  desc = "TODO consider deleting" },
            { "<leader>tc",  desc = "Toggle CSV View", cond = function() return vim.tbl_contains({ "csv", "tsv" }, vim.bo.filetype) end },

            -- Avante
            { "<leader>a",   group = "Avante" },
            { "<leader>am",  desc = "Toggle my prompt" },

            -- OpenCode
            { "<leader>o",   group = "OpenCode" },
            { "<leader>ot",  desc = "Toggle opencode" },
            { "<leader>oA",  desc = "Ask opencode" },
            { "<leader>oa",  desc = "Ask opencode about this" },
            { "<leader>on",  desc = "New opencode session" },
            { "<leader>oy",  desc = "Copy last opencode response" },
            { "<leader>os",  desc = "Select opencode prompt" },
            { "<leader>oe",  desc = "Explain this code" },

            -- Find commands group
            { "<leader>f",   group = "Find" },
            -- File and buffer operations
            { "<leader>ff",  desc = "Find Files" },
            { "<leader>fF",  desc = "Find Git Files" },
            { "<leader>fb",  desc = "Find Buffers" },
            { "<leader>fm",  desc = "Find Markdown Headings" },
            -- Search operations
            { "<leader>fg",  desc = "Find with Live Grep" },
            { "<leader>fG",  desc = "Find with Grep String" },
            { "<leader>fws", desc = "Find Highlighted Word" },
            { "<leader>fWs", desc = "Find Full Highlighted Word" },
            -- Git operations
            { "<leader>fr",  desc = "Find Git Worktree" },
            { "<leader>fR",  desc = "Create Git Worktree" },
            { "<leader>fc",  desc = "Find Git Commits" },
            { "<leader>fC",  desc = "Find Git Commits for Buffer" },
            { "<leader>fi",  desc = "Find with Advanced Git Search" },
            -- LSP and diagnostics
            { "<leader>fd",  desc = "Find Diagnostics" },
            { "<leader>fs",  desc = "Find Symbols" },
            -- Help and keymaps
            { "<leader>fh",  desc = "Find Help Tags" },
            { "<leader>fk",  desc = "Find Keymaps" },
            -- Notifications and clipboard
            { "<leader>fn",  desc = "Find Notifications" },
            { "<leader>fN",  desc = "Find Noice Messages" },
            { "<leader>fy",  desc = "Find Clipboard History" },
            -- Harpoon
            { "<leader>fp",  desc = "Find Harpoon Marks" },
            { "<leader>ft",  desc = "Find TODOs" },

            -- Other groups
            { "<leader>gt",  desc = "Neogit" },
            { "<leader>m",   group = "Markdown" },
            { "<leader>mp",  desc = "Toggle Markdown Preview" },
            {
                cond = function() return vim.tbl_contains({ "r", "rmd", "quarto" }, vim.bo.filetype) end,
                { "<leader>r",   group = "R Commands" },
                { "<leader>rf",  desc = "R Format Function" },
                { "<leader>rr",  desc = "R Unformat Function" },
                { "<leader>rh",  desc = "Convert read.csv to read_csv and use here()" },
                { "<leader>ri",  desc = "Install R package with renv" },
                { "<leader>rR",  desc = "renv Restore" },
                { "<leader>rI",  desc = "Initialize renv" },
                { "<leader>rs",  desc = "renv status" },
                { "<leader>rS",  desc = "renv snapshot" },
                { "<leader>rd",  desc = "Roxygen Document" },
                { "<leader>rC",  desc = "Run R CMD check" },
                { "<leader>rc",  desc = "Toggle R package prefixing" },
                { "<leader>rl",  desc = "Load all packages" },
                { "<leader>rt",  desc = "Test active file" },
                { "<leader>rT",  desc = "Test all" },
                { "<leader>rk",  desc = "Test coverage active file" },
                { "<leader>rK",  desc = "Test coverage all" },
                { "<leader>rv",  desc = "View object under cursor" },
                { "<leader>rV",  desc = "Send pipe chain & View" },
                { "<leader>ru",  group = "usethis Commands" },
                { "<leader>rut", desc = "usethis Test" },
                { "<leader>rup", desc = "usethis Package (Imports)" },
                { "<leader>rus", desc = "usethis Package (Suggests)" },
            },
            { "<leader>df",  desc = "Diffview Toggle" },
            { "<leader>hS",  desc = "Stage Buffer" },
            { "<leader>ha",  desc = "Stage Hunk" },
            { "<leader>hu",  desc = "Undo Stage Hunk" },
            { "<leader>hR",  desc = "Reset Buffer" },
            { "<leader>hp",  desc = "Preview Hunk" },
            { "<leader>hb",  desc = "Blame Line" },
            { "<leader>tB",  desc = "Toggle Current Line Blame" },
            { "<leader>hd",  desc = "Diff This on Index" },
            { "<leader>hD",  desc = "Diff This on Last Commit" },
            { "<leader>gc",  desc = "ChatGPT" },
            { "<leader>ge",  desc = "Edit with instruction" },
            { "<leader>gd",  desc = "Docstring" },
            { "<leader>gx",  desc = "Explain Code" },
            { "<leader>gr",  desc = "Roxygen Edit" },
            { "<leader>gl",  desc = "Code Readability Analysis" },
        })
    end,
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    },
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "Buffer Local Keymaps (which-key)",
        },
    },
}
