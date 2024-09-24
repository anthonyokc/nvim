return {
    "stevearc/oil.nvim",
    config = function()
        require("oil").setup()
        vim.keymap.set("n", "<C-o>", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })
    end
}
