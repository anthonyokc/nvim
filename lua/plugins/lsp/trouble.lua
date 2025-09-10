return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "Trouble" },
    opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
    },
    keys = {
      --  { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Show Diagnostics" },
      --  { "<leader>xw", "<cmd>Trouble workspace_diagnostics toggle<cr>", desc = "Workspace Diagnostics" },
      --  { "<leader>xd", "<cmd>Trouble document_diagnostics toggle<cr>", desc = "Document Diagnostics" },
      --  { "<leader>xq", "<cmd>Trouble quickfix toggle<cr>", desc = "Quickfix List" },
      --  { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
      --  { "gR",         "<cmd>Trouble lsp_references toggle<cr>", desc = "LSP References" },
    },
}
