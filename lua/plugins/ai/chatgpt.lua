return {
    {
        "jackMort/ChatGPT.nvim",
        command = { "ChatGPT", "ChatGPTEditWithInstruction", "ChatGPTRun" },
        config = function()
            require("chatgpt").setup({
                openai_params = {
                    model = "gpt-4o-2024-08-06",
                    frequency_penalty = 0,
                    presence_penalty = 0,
                    max_tokens = 4095,
                    temperature = 0.2,
                    top_p = 0.1,
                    n = 1,
                },
                popup_input = {
                    submit = "<C-s>",
                    submit_n = "<C-s>"
                }
            })
        end,
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "folke/trouble.nvim",
            "nvim-telescope/telescope.nvim"
        },
        keys = {
            { "<leader>gr", "<cmd>ChatGPTRun roxygen_edit<CR>",              desc = "Roxygen Edit" },
        }
    }
}
