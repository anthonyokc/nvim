return {
    {
        'NickvanDyke/opencode.nvim',
        event = 'VeryLazy',
        dependencies = {
           -- Recommended for better prompt input, and required to use `opencode.nvim`'s embedded terminal — otherwise optional
           { "folke/snacks.nvim", opts = { input = { enabled = true }, picker = {}, terminal = {} } },
       },
       config = function()
           require("config.ai.opencode").setup()
       end,
   },
}
