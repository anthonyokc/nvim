return {
    "jalvesaq/Nvim-R",
    ft = {'r', 'rmd', 'qmd'},
    config = function ()
        vim.keymap.set("n", "<leader>r", ":call StartR('R')<CR>")
        vim.keymap.set("i", "<leader>r", "<Esc>:call StartR('R')<CR>")
        vim.keymap.set("v", "<leader>r", "<Esc>:call StartR('R')<CR>")

        vim.keymap.set("n", ",", "<Plug>RDSendLine")
        vim.keymap.set("v", ",", "<Plug>RDSendSelection")
        vim.keymap.set("v", ",e", "<Plug>RESendSelection")

        -- R output is highlighted with current colorscheme
        vim.g.rout_follow_colorscheme = 1
        -- R commands in R output are highlighted
        vim.g.Rout_more_colors = 1

        vim.opt.tabstop = 2
        vim.opt.softtabstop = 2
        vim.opt.shiftwidth = 2

        local function map(mode, lhs, rhs, opts)
          local options = {noremap = true}
          if opts then options = vim.tbl_extend('force', options, opts) end
          vim.api.nvim_set_keymap(mode, lhs, rhs, options)
        end

        map('i', '<C-k>', ' |> ', { noremap = true, silent = true})
        map('i', '<C-m>', ' <- ', { noremap = true, silent = true})

    end
}
