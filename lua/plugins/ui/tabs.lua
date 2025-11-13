-- This is what powers LazyVim's fancy-looking
-- tabs, which include filetype icons and close buttons.
return {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
        { "<S-h>",      "<cmd>BufferLineCyclePrev<cr>",            desc = "Prev Buffer" },
        { "<S-l>",      "<cmd>BufferLineCycleNext<cr>",            desc = "Next Buffer" },
        { "[b",         "<cmd>BufferLineCyclePrev<cr>",            desc = "Prev Buffer" },
        { "]b",         "<cmd>BufferLineCycleNext<cr>",            desc = "Next Buffer" },
        { "[B",         "<cmd>BufferLineMovePrev<cr>",             desc = "Move buffer prev" },
        { "]B",         "<cmd>BufferLineMoveNext<cr>",             desc = "Move buffer next" },
    },
    opts = {
        options = {
            mode = "tabs", -- Show only actual vim tabs, not buffers
            -- stylua: ignore
            close_command = function(n) Snacks.bufdelete(n) end,
            -- stylua: ignore
            right_mouse_command = function(n) Snacks.bufdelete(n) end,
            diagnostics = "nvim_lsp",
            always_show_bufferline = false, -- Only show when there are at least two tabs
            show_buffer_icons = true, -- Keep the cool icons
            show_tab_indicators = true,
            offsets = {
                {
                    filetype = "neo-tree",
                    text = "Neo-tree",
                    highlight = "Directory",
                    text_align = "left",
                },
                {
                    filetype = "snacks_layout_box",
                },
            },
        },
    },
    config = function(_, opts)
        require("bufferline").setup(opts)
        -- Fix bufferline when restoring a session
        vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
            callback = function()
                vim.schedule(function()
                    pcall(nvim_bufferline)
                end)
            end,
        })
    end,
}
