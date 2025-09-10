-- all.lua: Snippets for all file types.
-- These snippets are available in any file type
local ls = require("luasnip")
local s, t, i, c = ls.snippet, ls.text_node, ls.insert_node, ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt


-- Basic palette: RGB primaries + common basics
_G.C = {
    red = "#ff0000",
    green = "#00ff00",
    blue = "#0000ff",
    yellow = "#ffff00",
    magenta = "#ff00ff",
    cyan = "#00ffff",
    black = "#000000",
    white = "#ffffff",
    gray = "#808080",
    orange = "#ffa500",
    purple = "#800080",
    pink = "#ffc0cb",
    teal = "#008080",
}

ls.add_snippets("all", {
    s("hl", fmt([[vim.api.nvim_set_hl(0, "{}", {{ {} = C.{}, {} = {}, reverse = {} }})]], {
        i(1, "PmenuSel"),
        c(2, { t "fg", t "bg", t "sp" }),
        c(3, {
            t "red", t "green", t "blue", t "yellow", t "magenta", t "cyan",
            t "black", t "white", t "gray", t "orange", t "purple", t "pink", t "teal"
        }),
        c(4, { t '"NONE"', t "C.black", t "C.white" }),
        c(5, { t "false", t "true" }),
    })),
})
