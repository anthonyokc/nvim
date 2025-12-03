return {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {
        fast_wrap = {},
        map_c_w = true, -- enable mapping for <C-w> to delete a pair if possible
    },
    config = function(_, opts)

        require("nvim-autopairs").setup(opts)

        -- Make <Tab> move out of parens if cursor is before ')'
        vim.keymap.set("i", "<Tab>", function()
            local col = vim.fn.col(".")
            local line = vim.fn.getline(".")
            if line:sub(col, col) == ")" then
                return "<Right>"
            end
            return "<Tab>"
        end, { expr = true })
    end,
}
