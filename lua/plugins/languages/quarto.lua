return {

    { -- requires plugins in lua/plugins/treesitter.lua and lua/plugins/lsp.lua
        -- for complete functionality (language features)
        'quarto-dev/quarto-nvim',
        ft = { 'quarto', 'qmd' },
        dev = false,
        dependencies = {
            -- for language features in code cells
            -- configured in lua/plugins/lsp.lua and
            -- added as a nvim-cmp source in lua/plugins/completion.lua
            'jmbuhr/otter.nvim',
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            local quarto = require('quarto')

            quarto.setup()
            vim.keymap.set('n', '<leader>qp', quarto.quartoPreview, { silent = true, noremap = true })
            vim.api.nvim_create_autocmd('FileType', {
                group = vim.api.nvim_create_augroup('QuartoRFormatting', { clear = true }),
                pattern = { 'quarto', 'qmd' },
                callback = function(args)
                    vim.keymap.set('n', '<leader>F', function()
                        require('conform').format({
                            bufnr = args.buf,
                            timeout_ms = 5000,
                            lsp_format = 'fallback',
                        })
                    end, {
                        buffer = args.buf,
                        silent = true,
                        desc = 'Format embedded code blocks',
                    })
                end,
            })
        end
    },

    {
        'stevearc/conform.nvim',
        ft = { 'r', 'rmd', 'quarto', 'qmd' },
        cmd = { 'ConformInfo' },
        opts = {
            formatters_by_ft = {
                r = { 'styler_text' },
                rmd = { 'injected_r' },
                quarto = { 'injected_r' },
                qmd = { 'injected_r' },
            },
            default_format_opts = {
                lsp_format = 'fallback',
            },
            formatters = {
                styler_text = {
                    inherit = false,
                    command = 'R',
                    args = {
                        '--no-init-file',
                        '-s',
                        '-e',
                        'writeLines(styler::style_text(readLines(file("stdin"))))',
                    },
                    stdin = true,
                },
                injected_r = {
                    inherit = 'injected',
                    options = {
                        lang_to_ext = {
                            r = 'rconform',
                        },
                        lang_to_formatters = {
                            r = { 'styler_text' },
                        },
                    },
                },
            },
        },
    },

    { -- directly open ipynb files as quarto docuements
        -- and convert back behind the scenes
        'GCBallesteros/jupytext.nvim',
        opts = {
            custom_language_formatting = {
                python = {
                    extension = 'qmd',
                    style = 'quarto',
                    force_ft = 'quarto',
                },
                r = {
                    extension = 'qmd',
                    style = 'quarto',
                    force_ft = 'quarto',
                },
            },
        },
    },

    { -- send code from python/r/qmd documets to a terminal or REPL
        -- like ipython, R, bash
        'jpalardy/vim-slime',
        dev = false,
        init = function()
            vim.b['quarto_is_python_chunk'] = false
            Quarto_is_in_python_chunk = function()
                require('otter.tools.functions').is_otter_language_context 'python'
            end

            vim.cmd [[
      let g:slime_dispatch_ipython_pause = 100
      function SlimeOverride_EscapeText_quarto(text)
      call v:lua.Quarto_is_in_python_chunk()
      if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk && !(exists('b:quarto_is_r_mode') && b:quarto_is_r_mode)
      return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
      else
      if exists('b:quarto_is_r_mode') && b:quarto_is_r_mode && b:quarto_is_python_chunk
      return [a:text, "\n"]
      else
      return [a:text]
      end
      end
      endfunction
      ]]

            vim.g.slime_target = 'neovim'
            vim.g.slime_no_mappings = true
            vim.g.slime_python_ipython = 1
        end,
        config = function()
            vim.g.slime_input_pid = false
            vim.g.slime_suggest_default = true
            vim.g.slime_menu_config = false
            vim.g.slime_neovim_ignore_unlisted = true

            local function mark_terminal()
                local job_id = vim.b.terminal_job_id
                vim.print('job_id: ' .. job_id)
            end

            local function set_terminal()
                vim.fn.call('slime#config', {})
            end
            vim.keymap.set('n', '<leader>cm', mark_terminal, { desc = '[m]ark terminal' })
            vim.keymap.set('n', '<leader>cs', set_terminal, { desc = '[s]et terminal' })
        end,
    },


    { -- preview equations
        'jbyuki/nabla.nvim',
        keys = {
            { '<leader>qm', ':lua require"nabla".toggle_virt()<cr>', desc = 'toggle [m]ath equations' },
        },
    },

    {
        'benlubas/molten-nvim',
        enabled = false,
        build = ':UpdateRemotePlugins',
        init = function()
            vim.g.molten_image_provider = 'image.nvim'
            vim.g.molten_output_win_max_height = 20
            vim.g.molten_auto_open_output = false
        end,
        keys = {
            { '<leader>mi', ':MoltenInit<cr>',           desc = '[m]olten [i]nit' },
            {
                '<leader>mv',
                ':<C-u>MoltenEvaluateVisual<cr>',
                mode = 'v',
                desc = 'molten eval visual',
            },
            { '<leader>mr', ':MoltenReevaluateCell<cr>', desc = 'molten re-eval cell' },
        },
    },
}
