return {
    {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            require("ibl").setup({
                scope = { enabled = false },
            })
        end
    },
    {
        'echasnovski/mini.indentscope',
        version = false,
        config = function()
            require('mini.indentscope').setup({

                -- Draw options
                draw = {
                    -- Delay (in ms) between event and start of drawing scope indicator
                    delay = 0,
                    -- Animation rule for scope's first drawing. A function which, given
                    -- next and total step numbers, returns wait time (in ms). See
                    -- |MiniIndentscope.gen_animation| for builtin options. To disable
                    animation = require('mini.indentscope').gen_animation.none(),
                    -- animation = require('mini.indentscope').gen_animation.quadratic({ easing = 'out', duration = 200, unit = 'total' })

                    -- Which character to use for drawing scope indicator
                    -- symbol = '╎',
                },
                symbol = '│',

            })
        end,
    },
}
