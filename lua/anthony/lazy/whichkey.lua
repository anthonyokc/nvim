return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
        local wk =  require("which-key")
        wk.add({
            -- Case conversion commands
            { "su",          desc = "Convert to lowercase" },
            { "sU",          desc = "Convert to uppercase" },
            { "s~",          desc = "Toggle case" },
            { "gu",          desc = "Convert to lowercase (with motion)" },
            { "gU",          desc = "Convert to uppercase (with motion)" },
            { "g~",          desc = "Toggle case (with motion)" },

            -- Find commands group
            { "<leader>f",   group = "Find" },
            -- File and buffer operations
            { "<leader>ff",  desc = "Find Files" },
            { "<leader>fF",  desc = "Find Git Files" },
            { "<leader>fb",  desc = "Find Buffers" },
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
            { "<leader>fm",  desc = "Find Harpoon Marks" },
            { "<leader>ft",  desc = "Find TODOs" },

            -- Other groups
            { "<leader>a",   desc = "Avante" },
            { "<leader>gt",  desc = "Neogit" },
            { "<leader>m",   group = "Markdown" },
            { "<leader>mp",  desc = "Toggle Markdown Preview" },
            { "<leader>r",   group = "R Commands" },
            { "<leader>rf",  group = "R Format Function" },
            { "<leader>rr",  group = "R Unformat Function" },
            { "<leader>rR",  group = "renv Restore" },
            { "<leader>rh",  desc = "Convert read.csv to read_csv and use here()" },
            { "<leader>ri",  desc = "Install R package with renv" },
            { "<leader>rI",  desc = "Initialize renv" },
            { "<leader>rs",  desc = "renv status" },
            { "<leader>rS",  desc = "renv snapshot" },
            { "<leader>rd",  desc = "Roxygen Document" },
            { "<leader>rc",  desc = "Run R CMD check" },
            { "<leader>rl",  desc = "Load all packages" },
            { "<leader>rt",  desc = "Test active file" },
            { "<leader>rT",  desc = "Test all" },
            { "<leader>rv",  desc = "Test coverage active file" },
            { "<leader>rV",  desc = "Test coverage all" },
            { "<leader>ru",  group = "usethis Commands" },
            { "<leader>rut", desc = "usethis Test" },
            { "<leader>rup", desc = "usethis Package (Imports)" },
            { "<leader>rus", desc = "usethis Package (Suggests)" },
            { "<leader>df",  desc = "Diffview Open" },
            { "<leader>df",  desc = "Diffview Close" },
            { "<leader>hS",  desc = "Stage Buffer" },
            { "<leader>ha",  desc = "Stage Hunk" },
            { "<leader>hu",  desc = "Undo Stage Hunk" },
            { "<leader>hR",  desc = "Reset Buffer" },
            { "<leader>hp",  desc = "Preview Hunk" },
            { "<leader>hb",  desc = "Blame Line" },
            { "<leader>tB",  desc = "Toggle Current Line Blame" },
            { "<leader>hd",  desc = "Diff This on Index" },
            { "<leader>hD",  desc = "Diff This on Last Commit" },
            { "<leader>g",   group = "ChatGPT.nvim" },
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
