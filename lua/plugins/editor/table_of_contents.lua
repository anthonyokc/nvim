return {
    {
        "stevearc/aerial.nvim",
        cmd = { "AerialToggle", "AerialOpen", "AerialInfo" },
        config = function()
            require("aerial").setup({
                backends = { "treesitter", "lsp", "markdown" }, -- prefer TS
                nerd_font = "auto",                             -- or false if you want pure ASCII
                icons = {
                    Module    = "",                             -- H1  (#! ...)
                    Namespace = "",                             -- H2  (#!! ...)
                    Package   = "",                             -- P   (#!!! ...)
                },
                manage_folds = false,                           -- keep outline folded after jumping
                link_folds_to_tree = true,                      -- auto open/close tree based on folds
                link_tree_to_folds = true,                      -- auto open/close folds based on tree
                filter_kind = false,                            -- show all kinds
                -- optionally use on_attach to set keymaps when aerial has attached to a buffer
                on_attach = function(bufnr)
                    -- Jump forwards/backwards with '{' and '}'
                    vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
                    vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
                end,
                -- Re-parent symbols under nearest heading created from comments
                -- only this part changes
                post_add_all_symbols = function(_, items, _)
                    local function last(t) return t and t[#t] end
                    local function line(it)
                        return it.lnum
                            or (it.selection_range and it.selection_range.start and it.selection_range.start.line)
                            or (it.range and it.range.start and it.range.start.line)
                            or 0
                    end
                    local function is_h1(it)
                        return it.detail == "H1" or (it.name and it.name:match("^#%s"))
                    end
                    local function is_h2(it)
                        return it.detail == "H2" or (it.name and it.name:match("^##%s"))
                    end
                    local function is_h3(it)
                        return it.detail == "H3" or (it.name and it.name:match("^###%s"))
                    end

                    -- 1) Flatten, keep original nodes
                    local flat = {}
                    local function walk(ts)
                        for _, it in ipairs(ts or {}) do
                            table.insert(flat, it)
                            if it.children then walk(it.children) end
                        end
                    end
                    walk(items)
                    table.sort(flat, function(a, b) return line(a) < line(b) end)

                    -- 2) Detach everything (keep node objects)
                    for _, n in ipairs(flat) do
                        if n.parent then
                            local p = n.parent
                            for i = #p.children, 1, -1 do
                                if p.children[i] == n then
                                    table.remove(p.children, i)
                                    break
                                end
                            end
                            n.parent = nil
                        end
                        n.children = {}
                        n.level = 0
                    end

                    -- 3) Rebuild hierarchy
                    local roots, h1s, h2s, h3s = {}, {}, {}, {}
                    local function adopt(child, parent)
                        if parent then
                            child.parent = parent
                            table.insert(parent.children, child)
                            child.level = (parent.level or 0) + 1
                        else
                            table.insert(roots, child)
                            child.level = 0
                        end
                    end

                    for _, it in ipairs(flat) do
                        if is_h1(it) then -- attach H1 directly to root
                            adopt(it, nil)
                            table.insert(h1s, it)
                            -- reset lower levels when a new H1 starts
                            h2s = {}
                            h3s = {}
                        elseif is_h2(it) then -- attach H2 under nearest previous H1
                            local p = last(h1s)
                            adopt(it, p)
                            table.insert(h2s, it)
                            -- reset deeper level when a new H2 starts
                            h3s = {}
                        elseif is_h3(it) then -- attach H3 under nearest previous H2, else H1
                            local p = last(h2s) or last(h1s)
                            adopt(it, p)
                            table.insert(h3s, it)
                        else -- attach everything else under nearest previous H3, H2, or H1
                            local p = last(h3s) or last(h2s) or last(h1s)
                            adopt(it, p)
                        end
                    end

                    -- 4) Mutate the *same* `items` table to be the new roots
                    for i = #items, 1, -1 do items[i] = nil end
                    for _, r in ipairs(roots) do table.insert(items, r) end
                    return items
                end
            })
            -- You probably also want to set a keymap to toggle aerial
            vim.keymap.set("n", "<leader>to", "<cmd>AerialToggle!<CR>")
            vim.api.nvim_set_hl(0, "AerialModuleIcon", { link = "Title" })
            vim.api.nvim_set_hl(0, "AerialNamespaceIcon", { link = "Identifier" })
            vim.api.nvim_set_hl(0, "AerialFunctionIcon", { link = "Function" })
        end,
    },
    {
        "hedyhli/outline.nvim",
        -- lazy = true,
        -- cmd = { "Outline", "OutlineOpen" },
        config = function()
            -- Example mapping to toggle outline
            vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>",
                { desc = "Toggle Outline" })
            require("outline").setup {
                -- Your setup opts here (leave empty to use defaults)
            }
        end,
    },
}
