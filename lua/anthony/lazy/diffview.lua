return {
    "sindrets/diffview.nvim",
    config = function ()
        require("diffview").setup()
        vim.keymap.set("n", "<leader>df", vim.cmd.DiffviewOpen)
        vim.keymap.set("n", "<leader>q", vim.cmd.DiffviewClose)
    end
}
