-- This part decides which colorscheme to use in Neovim.
-- It also sets some basic highlight groups to ensure a transparent background.
function ColorMyPencils(color)
    color = color or "catppuccin" -- Default to "catppuccin" if no color is specified
    vim.cmd.colorscheme(color) -- Set the colorscheme


    -- Set some basic highlight groups to ensure a transparent background
    -- Setting { bg = "none" } makes them transparent so your terminal background shows through.
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })          -- "Normal" → main editor text area
    vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
    vim.api.nvim_set_hl(0, "FloatTitle", { bg = "none" })
    vim.api.nvim_set_hl(0, "FloatFooter", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })     -- "NormalFloat" → floating windows (popups)
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })     -- "NormalNC" → non-current windows
end

-- Theme options
return {
    {
        "folke/tokyonight.nvim",
        config = function()
            require("tokyonight").setup({
                -- your configuration comes here
                -- or leave it empty to use the default settings
                style = "storm",        -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
                transparent = true,     -- Enable this to disable setting the background color
                terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
                styles = {
                    -- Style to be applied to different syntax groups
                    -- Value is any valid attr-list value for `:help nvim_set_hl`
                    comments = { italic = false },
                    keywords = { italic = false },
                    -- Background styles. Can be "dark", "transparent" or "normal"
                    sidebars = "dark", -- style for sidebars, see below
                    floats = "dark",   -- style for floating windows
                },
            })
        end
    },

    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,    -- make sure we load this during startup if it is your main colorscheme
        priority = 1000, -- make sure to load this before all the other start plugins
        config = function()
            require("catppuccin").setup({
                flavour = "mocha"
            })

            vim.cmd("colorscheme catppuccin")

            ColorMyPencils()
        end
    },

    {
        "chrisbra/Colorizer",
        config = function()
            vim.cmd.ColorToggle()
            require('avante_lib').load()
        end
    },

    {
        "HiPhish/rainbow-delimiters.nvim"
    }
}
