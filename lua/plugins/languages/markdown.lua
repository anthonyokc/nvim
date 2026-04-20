return {
    {
        'OXY2DEV/markview.nvim',
        event = 'VeryLazy',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
        },
        config = function()
            local presets = require("markview.presets")

            require("markview").setup({
                preview = {
                    filetypes = { "markdown", "Avante", "quarto", "rmd" },
                    hybrid_modes = { "n" },
                },
                markdown = {
                    headings = {
                        shift_width = 1,

                        heading_1 = {
                            style = "icon",
                            icon = "[%d] ",
                            hl = "MarkviewHeading1",
                        },
                        heading_2 = {
                            style = "icon",
                            icon = "[%d.%d] ",
                            hl = "MarkviewHeading2",
                        },
                        heading_3 = {
                            style = "icon",
                            icon = "[%d.%d.%d] ",
                            hl = "MarkviewHeading3",
                        },
                        heading_4 = {
                            style = "icon",
                            icon = "[%d.%d.%d.%d] ",
                            hl = "MarkviewHeading4",
                        },
                        heading_5 = {
                            style = "icon",
                            icon = "[%d.%d.%d.%d.%d] ",
                            hl = "MarkviewHeading5",
                        },
                        heading_6 = {
                            style = "icon",
                            icon = "[%d.%d.%d.%d.%d.%d] ",
                            hl = "MarkviewHeading6",
                        },

                        setext_1 = {
                            style = "decorated",
                            icon = "  ",
                            hl = "MarkviewHeading1",
                            border = "▂",
                        },
                        setext_2 = {
                            style = "decorated",
                            icon = "  ",
                            hl = "MarkviewHeading2",
                            border = "▁",
                        },
                    },
                    code_blocks = {
                        style = "block",
                        min_width = 60,
                        pad_amount = 2,
                        pad_char = " ",
                        label_direction = "right",
                        sign = false,
                    },
                    tables = {
                        enable = true,
                        block_decorator = true,
                        use_virt_lines = false,
                    },
                    list_items = {
                        marker_minus = {
                            add_padding = true,
                            conceal_on_checkboxes = true,
                            text = "●",
                            hl = "MarkviewListItemMinus",
                        },
                        marker_plus = {
                            add_padding = true,
                            conceal_on_checkboxes = true,
                            text = "○",
                            hl = "MarkviewListItemPlus",
                        },
                        marker_star = {
                            add_padding = true,
                            conceal_on_checkboxes = true,
                            text = "◆",
                            hl = "MarkviewListItemStar",
                        },
                    },
                    horizontal_rules = presets.horizontal_rules.thin,
                },
            })

            -- Catppuccin Mocha palette
            local mocha = {
                red       = '#f38ba8',
                peach     = '#fab387',
                yellow    = '#f9e2af',
                green     = '#a6e3a1',
                sapphire  = '#74c7ec',
                mauve     = '#cba6f7',
                blue      = '#89b4fa',
                sky       = '#89dceb',
                teal      = '#94e2d5',
                lavender  = '#b4befe',
                pink      = '#f5c2e7',
                overlay2  = '#9399b2',
                base      = '#1e1e2e',
                mantle    = '#181825',
                surface0  = '#313244',
            }

            --- Darken a hex color toward base by a factor (0..1)
            local function darken(hex, amount)
                local r = tonumber(hex:sub(2, 3), 16)
                local g = tonumber(hex:sub(4, 5), 16)
                local b = tonumber(hex:sub(6, 7), 16)
                local br = tonumber(mocha.base:sub(2, 3), 16)
                local bg = tonumber(mocha.base:sub(4, 5), 16)
                local bb = tonumber(mocha.base:sub(6, 7), 16)
                r = math.floor(r + (br - r) * (1 - amount))
                g = math.floor(g + (bg - g) * (1 - amount))
                b = math.floor(b + (bb - b) * (1 - amount))
                return string.format('#%02x%02x%02x', r, g, b)
            end

            -- Palette colors: catppuccin rainbow used by markview's MarkviewPalette0-6
            -- Palette mapping: 0=overlay2, 1=red, 2=peach, 3=yellow, 4=green, 5=sapphire, 6=mauve, 7=mauve
            local palette = {
                [0] = mocha.overlay2,
                [1] = mocha.red,
                [2] = mocha.peach,
                [3] = mocha.yellow,
                [4] = mocha.green,
                [5] = mocha.sapphire,
                [6] = mocha.mauve,
                [7] = mocha.mauve,
            }
            local bg_amount = 0.28

            for i = 0, 7 do
                local color = palette[i]
                local bg_color = darken(color, bg_amount)
                vim.api.nvim_set_hl(0, 'MarkviewPalette' .. i, { fg = color, bg = bg_color })
                vim.api.nvim_set_hl(0, 'MarkviewPalette' .. i .. 'Fg', { fg = color })
                vim.api.nvim_set_hl(0, 'MarkviewPalette' .. i .. 'Bg', { bg = bg_color })
                vim.api.nvim_set_hl(0, 'MarkviewIcon' .. i, { fg = color, bg = mocha.mantle })
            end

            -- Heading highlights (link to palette: H1=Palette1, H2=Palette2, etc.)
            for i = 1, 6 do
                local color = palette[i]
                local bg_color = darken(color, bg_amount)
                vim.api.nvim_set_hl(0, 'MarkviewHeading' .. i, { fg = color, bg = bg_color, bold = true })
                vim.api.nvim_set_hl(0, 'MarkviewHeading' .. i .. 'Sign', { fg = color })
            end

            -- Code blocks
            vim.api.nvim_set_hl(0, 'MarkviewCode', { bg = mocha.mantle })
            vim.api.nvim_set_hl(0, 'MarkviewCodeFg', { fg = mocha.mantle })
            vim.api.nvim_set_hl(0, 'MarkviewCodeInfo', { fg = mocha.overlay2, bg = mocha.mantle })
            vim.api.nvim_set_hl(0, 'MarkviewInlineCode', { bg = mocha.surface0 })

            -- Block quotes
            vim.api.nvim_set_hl(0, 'MarkviewBlockQuoteDefault', { fg = mocha.overlay2 })
            vim.api.nvim_set_hl(0, 'MarkviewBlockQuoteError', { fg = mocha.red, bg = darken(mocha.red, bg_amount) })
            vim.api.nvim_set_hl(0, 'MarkviewBlockQuoteNote', { fg = mocha.blue, bg = darken(mocha.blue, bg_amount) })
            vim.api.nvim_set_hl(0, 'MarkviewBlockQuoteOk', { fg = mocha.green, bg = darken(mocha.green, bg_amount) })
            vim.api.nvim_set_hl(0, 'MarkviewBlockQuoteSpecial', { fg = mocha.mauve, bg = darken(mocha.pink, bg_amount) })
            vim.api.nvim_set_hl(0, 'MarkviewBlockQuoteWarn', { fg = mocha.yellow, bg = darken(mocha.yellow, bg_amount) })

            -- Tables
            vim.api.nvim_set_hl(0, 'MarkviewTableHeader', { fg = mocha.blue })

            -- Toggle keymap
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "markdown", "Avante", "r" },
                callback = function()
                    vim.keymap.set("n", "<leader>mR", "<cmd>Markview toggle<cr>",
                        { desc = "Toggle Markview", buffer = true })
                end,
            })

            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "markdown", "Avante", "quarto", "rmd" },
                callback = function()
                    vim.opt_local.wrap = true
                    vim.opt_local.linebreak = true
                    vim.opt_local.breakindent = true
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

            local ns_previewer = vim.api.nvim_create_namespace("telescope.previewers")

            local function ensure_telescope_loaded()
                local telescope_ok = pcall(require, "telescope")
                if not telescope_ok then
                    local lazy_ok, lazy = pcall(require, "lazy")
                    if lazy_ok then lazy.load({ plugins = { "telescope.nvim" } }) end
                    telescope_ok = pcall(require, "telescope")
                end
                if not telescope_ok then
                    vim.notify("telescope.nvim is required to find markdown headings.", vim.log.levels.ERROR)
                    return false
                end
                return true
            end

            local function find_markdown_headings(bufnr)
                if not ensure_telescope_loaded() then return end
                local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                local results = {}
                local counters = { 0, 0, 0, 0, 0, 0 }
                for lnum, line in ipairs(lines) do
                    local hashes, title = line:match("^(#+)%s+(.*)$")
                    if hashes then
                        local level = #hashes
                        if level <= 6 then
                            title = vim.trim(title)
                            if title == "" then title = "(empty heading)" end
                            counters[level] = counters[level] + 1
                            for i = level + 1, 6 do
                                counters[i] = 0
                            end
                            local parts = {}
                            for i = 1, level do
                                table.insert(parts, tostring(counters[i]))
                            end
                            local outline = table.concat(parts, ".")
                            table.insert(results, {
                                lnum = lnum,
                                outline = outline,
                                title = title,
                                ordinal = outline .. " " .. title .. " Line Number: " .. lnum,
                            })
                        end
                    end
                end
                if #results == 0 then
                    vim.notify("No markdown headings in this buffer.", vim.log.levels.INFO)
                    return
                end

                local pickers = require("telescope.pickers")
                local finders = require("telescope.finders")
                local conf = require("telescope.config").values
                local actions = require("telescope.actions")
                local action_state = require("telescope.actions.state")
                local previewers_mod = require("telescope.previewers")

                pickers.new({ initial_mode = "insert" }, {
                    prompt_title = "Markdown headings",
                    finder = finders.new_table({
                        results = results,
                        entry_maker = function(entry)
                            return {
                                value = entry.lnum,
                                display = string.format(
                                    "%-14s  %s  Line Number: %d",
                                    entry.outline,
                                    entry.title,
                                    entry.lnum
                                ),
                                ordinal = entry.ordinal,
                            }
                        end,
                    }),
                    previewer = previewers_mod.new_buffer_previewer({
                        title = "Heading preview",
                        dyn_title = function(_, entry)
                            return string.format("Line %s", tostring(entry.value))
                        end,
                        get_buffer_by_name = function()
                            return "md_headings_" .. tostring(bufnr)
                        end,
                        teardown = function(self)
                            if self.state and self.state.bufnr and vim.api.nvim_buf_is_valid(self.state.bufnr) then
                                pcall(vim.api.nvim_buf_clear_namespace, self.state.bufnr, ns_previewer, 0, -1)
                            end
                        end,
                        define_preview = function(self, entry, status)
                            if not vim.api.nvim_buf_is_valid(bufnr) then return end
                            local preview_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, preview_lines)
                            local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
                            pcall(vim.api.nvim_buf_set_option, self.state.bufnr, "filetype", ft)
                            local lnum = entry.value
                            vim.defer_fn(function()
                                if not self.state or not vim.api.nvim_buf_is_valid(self.state.bufnr) then return end
                                pcall(vim.api.nvim_buf_clear_namespace, self.state.bufnr, ns_previewer, 0, -1)
                                if lnum and lnum > 0 then
                                    pcall(
                                        vim.api.nvim_buf_add_highlight,
                                        self.state.bufnr,
                                        ns_previewer,
                                        "TelescopePreviewLine",
                                        lnum - 1,
                                        0,
                                        -1
                                    )
                                end
                                local win = self.state.winid or status.preview_win
                                if win and vim.api.nvim_win_is_valid(win) then
                                    pcall(vim.api.nvim_win_set_cursor, win, { lnum, 0 })
                                    pcall(vim.api.nvim_buf_call, self.state.bufnr, function()
                                        vim.cmd("norm! zz")
                                    end)
                                end
                            end, 50)
                        end,
                    }),
                    sorter = conf.generic_sorter({}),
                    attach_mappings = function(prompt_bufnr, _)
                        actions.select_default:replace(function()
                            local selection = action_state.get_selected_entry()
                            actions.close(prompt_bufnr)
                            if not selection or not selection.value then return end
                            local win = vim.fn.bufwinid(bufnr)
                            if win == -1 then
                                vim.api.nvim_set_current_buf(bufnr)
                                win = 0
                            else
                                vim.api.nvim_set_current_win(win)
                            end
                            vim.api.nvim_win_set_cursor(win, { selection.value, 0 })
                            vim.cmd("normal! zz")
                        end)
                        return true
                    end,
                }):find()
            end

            -- Checks each line to see if it matches a markdown heading (#, ##, etc.):
            -- It's called implicitly by Neovim's folding engine by vim.opt_local.foldexpr
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

            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "markdown", "Avante", "quarto", "rmd", "r" },
                callback = function(args)
                    vim.keymap.set("n", "<leader>fm", function() find_markdown_headings(args.buf) end, {
                        buffer = args.buf,
                        desc = "[P]Find headings",
                        silent = true,
                    })
                end,
            })

            -- Hook LSP/cmp markdown floats and sanitize R HTML noise
            local util = vim.lsp.util
            local sanitize = function(c)
                local s = require('util.markdown').sanitize_html
                return s and s(c) or c
            end
            local orig_open = util.open_floating_preview
            util.open_floating_preview = function(contents, syntax, float_opts, ...)
                if syntax == 'markdown' then
                    contents = sanitize(contents)
                    if type(contents) == 'string' then contents = { contents } end
                    if type(contents) == 'table' then
                        for i, line in ipairs(contents) do
                            contents[i] = line:gsub('```%s*rout', '```text')
                        end
                    end
                end
                return orig_open(contents, syntax, float_opts, ...)
            end
        end,

    },
    -- install with yarn or npm
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && yarn install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
            if vim.fn.has("wsl") == 1 then
                vim.cmd([[
                function! OpenMarkdownPreviewWSL(url) abort
                  call jobstart([expand('~/scripts/brave_wsl_open.sh'), a:url], {'detach': v:true})
                endfunction
                ]])
                vim.g.mkdp_browserfunc = "OpenMarkdownPreviewWSL"
            end
        end,
        ft = { "markdown" },
        keys = {
            { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Toggle Markdown Preview", ft = "markdown" },
        },
    },
}
