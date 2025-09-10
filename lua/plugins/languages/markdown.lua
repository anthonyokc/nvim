return {
    {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = { "markdown", "r", "Avante" },
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
        -- install without yarn or npm
        config = function(_, opts)
            require("render-markdown").setup({
                code = {
                    language_border = ' ',
                    language_left = '',
                    language_right = '',
                },
                heading = {
                    width = 'block',
                    min_width = 30,
                    sign = false
                }
            })
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "markdown", "Avante", "r" },
                callback = function()
                    vim.keymap.set("n", "<leader>mR", "<cmd>RenderMarkdown toggle<cr>",
                        { desc = "Toggle Render Markdown", buffer = true })
                end,
            })
            ------------------------------------------------------------------------------
            --                           Folding section
            -------------------------------------------------------------------------------
            -- one-time: lets foldexpr call a buffer-local function
            if not _G.__md_foldexpr then
                _G.__md_foldexpr = function()
                    local f = vim.b.__md_foldexpr
                    return f and f() or "="
                end
            end


            -- Checks each line to see if it matches a markdown heading (#, ##, etc.):
            -- It’s called implicitly by Neovim’s folding engine by vim.opt_local.foldexpr
            -- buffer-local setup for markdown folding
            local function set_markdown_folding()
                -- detect frontmatter end once
                do
                    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                    local first
                    for i, ln in ipairs(lines) do
                        if ln == "---" then
                            if not first then
                                first = i
                            else
                                vim.b.frontmatter_end = i; break
                            end
                        end
                    end
                end

                -- buffer-local foldexpr function
                vim.b.__md_foldexpr      = function()
                    local lnum = vim.v.lnum
                    local line = vim.fn.getline(lnum)
                    local hashes = line:match("^(#+)%s")
                    if not hashes then return "=" end
                    local level = #hashes
                    if level == 1 then
                        if lnum == 1 then return ">1" end
                        local fm = vim.b.frontmatter_end
                        if fm and lnum == fm + 1 then return ">1" end
                        return ">1"
                    elseif level <= 6 then
                        return ">" .. level
                    end
                    return "="
                end

                vim.opt_local.foldmethod = "expr"
                vim.opt_local.foldexpr   = "v:lua.__md_foldexpr()"
                vim.opt_local.foldlevel  = 99
            end

            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "markdown", "r" },
                callback = function(args)
                    vim.api.nvim_buf_call(args.buf, set_markdown_folding)

                    local function km(lhs, rhs, desc)
                        vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc, silent = true })
                    end

                    local function fold_headings_of_level(level)
                        vim.api.nvim_win_set_cursor(0, { 1, 0 })
                        local total = vim.api.nvim_buf_line_count(0)
                        for l = 1, total do
                            local lc = vim.fn.getline(l)
                            if lc:match("^" .. string.rep("#", level) .. "%s") then
                                vim.api.nvim_win_set_cursor(0, { l, 0 })
                                if vim.fn.foldlevel(l) > 0 and vim.fn.foldclosed(l) == -1 then
                                    vim.cmd("normal! za")
                                end
                            end
                        end
                    end

                    local function fold_markdown_headings(levels)
                        local view = vim.fn.winsaveview()
                        vim.cmd("normal! zR") -- start unfolded for determinism
                        for _, lvl in ipairs(levels) do fold_headings_of_level(lvl) end
                        vim.fn.winrestview(view)
                    end

                    km("zj", function() fold_markdown_headings({ 6, 5, 4, 3, 2, 1 }) end, "[P]Fold H1+")
                    km("zk", function() fold_markdown_headings({ 6, 5, 4, 3, 2 }) end, "[P]Fold H2+")
                    km("zl", function() fold_markdown_headings({ 6, 5, 4, 3 }) end, "[P]Fold H3+")
                    km("z;", function() fold_markdown_headings({ 6, 5, 4 }) end, "[P]Fold H4+")
                    km("<S-Enter>", function()
                        local l = vim.fn.line(".")
                        if vim.fn.foldlevel(l) > 0 then vim.cmd("normal! za|zz") end
                    end, "[P]Toggle fold")
                    km("zu", function() vim.cmd("normal! zR|zz") end, "[P]Unfold all")
                    km("zi", function() vim.cmd("normal gk|normal! za|zz") end, "[P]Fold heading above")
                end,
            })
        end,

    },
    -- install with yarn or npm
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
        keys = {
            { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle Markdown Preview", ft = "markdown" },
        },
    },
}
