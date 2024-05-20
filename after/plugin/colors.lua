function color(color)
    color = color or "catppuccin"

    require("catppuccin").setup({
        flavour = "mocha"
    })
    vim.cmd.colorscheme(color)

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
end

color()
