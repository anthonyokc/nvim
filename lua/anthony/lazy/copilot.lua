return {
--     {
--         "zbirenbaum/copilot.lua",
--         cmd = "Copilot",
--         event = "InsertEnter",
--         config = function()
--             require("copilot").setup({
--                 suggestion = {
--                     enabled = true,
--                     auto_trigger = true,
--                     debounce = 20,
--                     keymap = {
--                         accept = "<C-CR>"
--                     }
--                 },
--                 panel = {
--                     enabled = true,
--                     keymap = {
--                         open = "<C-y>",
--                     }
--                 }
--             })
--             vim.api.nvim_set_keymap('i', '<C-j>', '<cmd>lua require("copilot.suggestion").accept()<CR>', {
--                 noremap = true
--             })
--         end
--     },
--     {
--         "zbirenbaum/copilot-cmp",
--         config = function()
--             require("copilot_cmp").setup()
--         end
--     }


         {
             "github/copilot.vim",
             opts = {
                 suggestion = {
                     keymap = { accept = "<C-CR>" }
                 },
                 panel = {
                     enabled = true,
                     auto_refresh = false,
                     keymap = {
                         jump_prev = "[[",
                         jump_next = "]]",
                         accept = "<CR>",
                         refresh = "gr",
                         open = "<M-CR>",
                     },
                     layout = {
                         position = "bottom", -- | top | left | right
                         ratio = 0.4,
                     },
                 },
             },
             config = function()
                 vim.keymap.set('i', '<C-j>', 'copilot#Accept("\\<CR>")', {
                     expr = true,
                     replace_keycodes = false
                 })
                 vim.g.copilot_no_tab_map = true
             end,
         }
}
