return {
    "jesseduffield/lazygit",
    cmd = "LazyGit",
    setup = function()
        vim.cmd [[
            nnoremap <leader>lg :LazyGit<CR>
        ]]
    end,
}
