return {
    "L3MON4D3/LuaSnip",
    config = function()
        local ls = require "luasnip"
        local s = ls.snippet
        local t = ls.text_node
        local i = ls.insert_node
        local extras = require("luasnip.extras")
        local rep = extras.rep
        local fmt = require("luasnip.extras.fmt").fmt
        local c = ls.choice_node
        local f = ls.function_node
        local d = ls.dynamic_node
        local sn = ls.snippet_node

        ls.add_snippets("r", {
            s("hello", {
                t('print("hello '),
                i(1),
                t(' world")')
            }),

            s("quarto", {
                t('---'
                ),
                i(1),
                t('```')

            }),

            s("if", {
                t('if '),
                i(1, "true"),
                t(' then '),
                i(2),
                t(' end')
            })
        })
    end
}
