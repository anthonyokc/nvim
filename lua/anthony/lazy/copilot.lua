return {
    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({})
        end
    },
    --     {
    --         "github/copilot.vim",
    --         opts = {
    --             suggestion = {
    --                 keymap = { accept = "<C-CR>" }
    --             },
    --             panel = {
    --                 enabled = true,
    --                 auto_refresh = false,
    --                 keymap = {
    --                     jump_prev = "[[",
    --                     jump_next = "]]",
    --                     accept = "<CR>",
    --                     refresh = "gr",
    --                     open = "<M-CR>",
    --                 },
    --                 layout = {
    --                     position = "bottom", -- | top | left | right
    --                     ratio = 0.4,
    --                 },
    --             },
    --         },
    --         config = function()
    --             vim.keymap.set('i', '<C-j>', 'copilot#Accept("\\<CR>")', {
    --                 expr = true,
    --                 replace_keycodes = false
    --             })
    --             vim.g.copilot_no_tab_map = true
    --         end,
    --     }
}
