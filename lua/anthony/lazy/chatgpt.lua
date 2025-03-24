return {
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
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
      { "<leader>gc", "<cmd>ChatGPT<CR>", desc = "ChatGPT" },
      { "<leader>ge", "<cmd>ChatGPTEditWithInstruction<CR>", desc = "Edit with instruction" },
      { "<leader>gd", "<cmd>ChatGPTRun docstring<CR>", desc = "Docstring" },
      { "<leader>gx", "<cmd>ChatGPTRun explain_code<CR>", desc = "Explain Code" },
      { "<leader>gr", "<cmd>ChatGPTRun roxygen_edit<CR>", desc = "Roxygen Edit" },
      { "<leader>gl", "<cmd>ChatGPTRun code_readability_analysis<CR>", desc = "Code Readability Analysis" },
    }
  }
}
