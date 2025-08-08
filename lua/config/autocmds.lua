-- Autocommands configuration
local augroup = vim.api.nvim_create_augroup
local ConfigGroup = augroup('ConfigGroup', {})
local YankGroup = augroup('HighlightYank', {})
local autocmd = vim.api.nvim_create_autocmd

-- Highlight yanked text
autocmd('TextYankPost', {
    group = YankGroup,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

-- Remove trailing whitespace on save
autocmd({ "BufWritePre" }, {
    group = ConfigGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

-- LSP key bindings
autocmd('LspAttach', {
    group = ConfigGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
        vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, opts)
    end
})

-- Open help files in a tab
autocmd('BufEnter', {
    pattern = '*.txt',
    callback = function()
        if vim.bo.filetype == 'help' then
            vim.cmd('wincmd T')
            vim.cmd('AerialToggle!')
        end
    end,
})

-- Avante AI prompt toggle
vim.api.nvim_create_autocmd("User", {
    pattern = "ToggleMyPrompt",
    callback = function() require("avante.config").override({ system_prompt =
        "You are an expert-level R programmer with knowledge about every niche package there is. You are assisting me on a coding task. I will sometimes provide you existing code, to help understand what I want to do. Whenever you reply, always aim to be concise and abide by tidy data principles and the tidyverse style guide." }) end,
})


-- iron.nvim REPL setup
vim.api.nvim_create_autocmd("FileType", {
    pattern = "nix",
    callback = function()
        require("iron.core").repl_for("nix") -- Ensure the REPL is set up for Nix files
    end,
})
