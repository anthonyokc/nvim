return {
    { -- This plugin
        "Zeioth/compiler.nvim",
        cmd = { "CompilerOpen", "CompilerToggleResults", "CompilerRedo" },
        dependencies = { "stevearc/overseer.nvim", "nvim-telescope/telescope.nvim" }, -- there are also system dependencies for the compilers themselves [this may or not be how you want them installed]: https://github.com/Zeioth/Compiler.nvim/wiki/how-to-install-the-required-dependencies
        opts = {},
    },
    { -- The task runner we use
        "stevearc/overseer.nvim",
        opts = {
            task_list = {
                direction = "bottom",
                min_height = 25,
                max_height = 25,
                default_detail = 1
            },
        },
        config = function(_, opts)
            require("overseer").register_template({
                name = "Build & run current file",
                builder = function()
                    local file     = vim.fn.expand("%:p")
                    local out      = vim.fn.expand("%:p:r")
                    local ft       = vim.bo.filetype
                    local is_win   = (vim.loop.os_uname().sysname or ""):match("Windows")
                    local sh, flag = (is_win and { "cmd", "/C" } or { "bash", "-lc" })[1],
                        (is_win and { "cmd", "/C" } or { "bash", "-lc" })[2]

                    local cmd      = ({
                        c      = ("gcc %q -O2 -g -o %q && %q"):format(file, out, out),
                        cpp    = ("g++ %q -O2 -g -std=c++20 -o %q && %q"):format(file, out, out),
                        rust   = ("rustc %q -o %q && %q"):format(file, out, out),
                        go     = ("go run %q"):format(file),
                        python = ("python3 %q"):format(file),
                        lua    = ("lua %q"):format(file),
                        sh     = ("bash %q"):format(file),
                    })[ft]

                    if not cmd then
                        vim.notify("No build&run template for filetype: " .. ft, vim.log.levels.ERROR)
                        return
                    end
                    return {
                        cmd = { sh, flag },
                        args = { cmd },
                        components = {
                            { "on_complete_notify", statuses = {} },
                            "default",
                            { "on_output_quickfix", open = true },
                            "on_result_diagnostics",
                            "unique"
                        },
                    }
                end,
                condition = { callback = function() return vim.fn.filereadable(vim.fn.expand("%:p")) == 1 end },
            })

            -- Keymap (put anywhere)
            vim.keymap.set("n", "<leader>b", function()
                require("overseer").run_template({ name = "Build & run current file" })
            end, { desc = "Build & run current file" })
        end
    },
}
