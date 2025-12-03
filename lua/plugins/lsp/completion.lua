return {
    {
        'saghen/blink.cmp',
        version = '1.*',
        event = 'InsertEnter',
        dependencies = {
            { 'nvim-mini/mini.nvim', version = false },
            -- Snippet completion
            'L3MON4D3/LuaSnip',             -- the snippet engine
            'rafamadriz/friendly-snippets', -- snippet collections

            {
                'saghen/blink.compat', -- compatibility layer for other completion sources from nvim-cmp
                version = '2.*',
                opt = {}
            },
            'jmbuhr/otter.nvim',      -- specialized completion for Quarto and RMarkdown documents
            "moyiz/blink-emoji.nvim", -- emoji completion
        },
        opts = {},
        config = function()
            local blink = require('blink.cmp')
            local luasnip = require('luasnip')

            -- Global toggle for R package prefixing
            vim.g.blink_cmp_r_prefix_enabled = vim.g.blink_cmp_r_prefix_enabled ~= nil and
                vim.g.blink_cmp_r_prefix_enabled or true

            blink.setup({
                sources = {
                    default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer', 'omni', 'emoji' },
                    per_filetype = {
                        r    = { 'lsp', 'path', 'snippets', 'buffer' },
                        rmd  = { 'lsp', 'path', 'snippets', 'buffer' },
                        qmd  = { 'lsp', 'path', 'snippets', 'buffer' },
                        sql  = { 'lsp', 'snippets', 'dadbod', 'buffer', },
                        psql = { 'lsp', 'snippets', 'dadbod', 'buffer', },
                    },
                    providers = {
                        lsp = {
                            -- Tranformers allow modifying completion items before they are displayed
                            transform_items = function(ctx, items)
                                -- Check if prefixing is enabled
                                if not vim.g.blink_cmp_r_prefix_enabled then
                                    return items
                                end

                                -- For R completions, add the `pkg::` prefix to functions
                                -- if the package name can be determined from the detail field
                                -- and if it's not already present
                                local ft = vim.bo[ctx.bufnr].filetype
                                if ft ~= "r" and ft ~= "rmd" and ft ~= "qmd" and ft ~= "rnoweb" then
                                    return items
                                end

                                for _, item in ipairs(items) do
                                    -- Only apply to function types (kind = 3)
                                    if item.kind == 3 then
                                        -- r_ls puts the environment/package name here
                                        local env = item.env

                                        if env then
                                            -- Strip prefixes like "package:" or "namespace:"
                                            local pkg = env:gsub("^package:", ""):gsub("^namespace:", "")

                                            -- Don't prefix globals, already-namespaced things, or R default packages
                                            local default_packages = {
                                                "base", "stats", "utils",
                                                "datasets", "graphics",
                                                "grDevices", "methods"
                                            }
                                            local is_default = false
                                            for _, default_pkg in ipairs(default_packages) do
                                                if pkg == default_pkg then
                                                    is_default = true
                                                    break
                                                end
                                            end

                                            if pkg ~= ".GlobalEnv" and not tostring(item.label):match("::") and not is_default then
                                                local base_label = item.label
                                                local base_insert = base_label

                                                -- What gets shown & inserted
                                                local shown = pkg .. "::" .. base_label
                                                local inserted = pkg .. "::" .. base_insert

                                                item.label = shown
                                                item.insertText = inserted

                                                -- 🔑 What the fuzzy matcher uses
                                                -- This keeps matching based on just `func`, not `pkg::func`
                                                item.filterText = base_insert
                                                item.sortText = base_insert
                                            end
                                        end
                                    end
                                end

                                return items
                            end,
                        },
                        dadbod = {
                            name = "Dadbod",
                            module = "vim_dadbod_completion.blink",
                            score_offset = 30,
                        },
                        lazydev = {
                            name = "LazyDev",
                            module = "lazydev.integrations.blink",
                            -- make lazydev completions top priority (see `:h blink.cmp`)
                            score_offset = 100,
                        },
                        emoji = {
                            module = "blink-emoji",
                            name = "Emoji",
                            score_offset = 15, -- Tune by preference
                            opts = {
                                insert = true, -- Insert emoji (default) or complete its name
                                ---@type string|table|fun():table
                                trigger = function()
                                    return { ":" }
                                end,
                            },
                        },
                    },
                },
                keymap = {
                    preset = 'default',
                    ['<C-e>'] = { 'show' },
                    ['<C-y>'] = { 'select_and_accept' },
                    ['<Tab>'] = { 'snippet_forward', 'select_and_accept', 'fallback' },
                    ['<S-Tab>'] = { 'snippet_backward', 'select_prev', 'fallback' },
                },

                -- Completion menu: the floating window that shows the list of completion items as you type
                completion = {
                    trigger = {
                        show_on_trigger_character = true,
                        show_on_blocked_trigger_characters = { '\n', '\t' }, -- allow space for R completions
                    },
                    menu = {
                        auto_show = true,

                        border = "rounded",
                        draw = {
                            columns = {
                                { "label",     "label_description", gap = 1 },
                                { "kind_icon", "kind",              "source_name", gap = 1 }
                            },
                        },
                    },
                    -- Documentation: the floating window that shows details about the currently selected completion item
                    documentation = {
                        window = { border = 'rounded' },
                        auto_show = true,
                        auto_show_delay_ms = 0,
                    },
                    list = {
                        selection = { preselect = true, auto_insert = true },
                    },
                },

                -- Signature help: the floating window that shows function signatures as you type
                signature = {
                    enabled = true,
                    trigger = {
                        -- Show the signature help automatically
                        enabled = true,
                        -- Show the signature help window after typing any of alphanumerics, `-` or `_`
                        show_on_keyword = false,
                        blocked_trigger_characters = {},
                        blocked_retrigger_characters = {},
                        show_on_trigger_character = true,           -- Show the signature help window after typing a trigger character
                        show_on_insert = true,                      -- Show the signature help window when entering insert mode
                        show_on_insert_on_trigger_character = true, -- Show the signature help window when the cursor comes after a trigger character when entering insert mode
                    },
                    window = {
                        min_width = 1,
                        max_width = 150,
                        max_height = 10,
                        border = "rounded", -- Defaults to `vim.o.winborder` on nvim 0.11+ or 'padded' when not defined/<=0.10
                        winblend = 0,
                        winhighlight = 'Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder',
                        direction_priority = { 'n', 's' },
                        treesitter_highlighting = true,
                        show_documentation = true,
                    },
                },
                cmdline = {
                    keymap = { preset = 'inherit' },
                    completion = { menu = { auto_show = true } },
                },

            })
            -- For blink.nvim completion menu
            -- Make the completion menu and doc window have a transparent background
            -- so that the colors from the main colorscheme show through
            -- NOTE: Aesthetic - Set up autocmd to apply highlights after colorscheme loads
            local function set_blink_highlights()
                vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = "NONE" })       -- menu body
                vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { bg = "NONE" }) -- menu border
                vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = "NONE" })        -- docs window body
                vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { bg = "NONE" })  -- docs window border
            end

            -- Set highlights after colorscheme is loaded and on colorscheme changes
            vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
                group = vim.api.nvim_create_augroup("BlinkCmpHighlights", { clear = true }),
                callback = function()
                    vim.schedule(set_blink_highlights) -- Use vim.schedule to ensure this runs after other highlight groups are set
                end,
                desc = "Set blink.cmp transparent highlights after colorscheme loads/changes"
            })
            -- Filetype-specific configurations are handled via the 'enabled' functions
            -- in the provider configurations above

            -- Load snippet collections
            require('luasnip.loaders.from_vscode').lazy_load()
            require('luasnip.loaders.from_vscode').lazy_load({
                paths = { vim.fn.stdpath('config') .. '/snips' }
            })

            -- Extend snippet filetypes
            luasnip.filetype_extend('quarto', { 'markdown' })
            luasnip.filetype_extend('rmarkdown', { 'markdown' })

            -- Toggle R package prefixing
            vim.keymap.set('n', '<leader>rc', function()
                vim.g.blink_cmp_r_prefix_enabled = not vim.g.blink_cmp_r_prefix_enabled
                local status = vim.g.blink_cmp_r_prefix_enabled and 'enabled' or 'disabled'
                vim.notify('R package prefixing ' .. status, vim.log.levels.INFO)
            end, { desc = 'Toggle R package prefixing' })
        end,
    }
}
