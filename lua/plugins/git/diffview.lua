return {
    "sindrets/diffview.nvim",
    event = "VeryLazy",
    config = function ()
        require("diffview").setup()
        vim.keymap.set("n", "<leader>df", vim.cmd.DiffviewOpen)
        vim.keymap.set("n", "<leader>dq", vim.cmd.DiffviewClose)
    end
}
