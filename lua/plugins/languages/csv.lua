return {
    {
        "hat0uma/csvview.nvim",
        cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle", "CsvViewInfo" },
        ft = { "csv", "tsv" },
        opts = {
            view = {
                display_mode = "border",
                header_lnum = 1,
            },
        },
        config = function(_, opts)
            require("csvview").setup(opts)
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "csv", "tsv" },
                callback = function(args)
                    vim.cmd("CsvViewEnable")
                    vim.keymap.set("n", "<leader>tc", "<cmd>CsvViewToggle<CR>", {
                        buffer = args.buf,
                        desc = "Toggle CSV View",
                        silent = true,
                    })
                end,
            })
        end,
    },
}
