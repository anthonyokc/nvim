return {
      { -- highlight markdown headings and code blocks etc.
        'lukas-reineke/headlines.nvim',
        enabled = false,
        dependencies = 'nvim-treesitter/nvim-treesitter',
        config = function()
          require('headlines').setup {
            quarto = {
              query = vim.treesitter.query.parse(
                'markdown',
                [[
                    (fenced_code_block) @codeblock
                    ]]
              ),
              codeblock_highlight = 'CodeBlock',
              treesitter_language = 'markdown',
            },
            markdown = {
              query = vim.treesitter.query.parse(
                'markdown',
                [[
                    (fenced_code_block) @codeblock
                    ]]
              ),
              codeblock_highlight = 'CodeBlock',
            },
          }
        end,
      },
      { -- show images in nvim!
        '3rd/image.nvim',
        enabled = true,
        dev = false,
        ft = { 'markdown', 'quarto', 'vimwiki' },
        dependencies = {
          {
            'vhyrro/luarocks.nvim',
            priority = 1001, -- this plugin needs to run before anything else
            opts = {
              rocks = { 'magick' },
            },
          },
        },
        config = function()
          -- Requirements
          -- https://github.com/3rd/image.nvim?tab=readme-ov-file#requirements
          -- check for dependencies with `:checkhealth kickstart`
          -- needs:
          -- sudo apt install imagemagick
          -- sudo apt install libmagickwand-dev
          -- sudo apt install liblua5.1-0-dev
          -- sudo apt installl luajit

          local image = require 'image'
          image.setup {
            backend = 'kitty',
            integrations = {
              markdown = {
                enabled = true,
                only_render_image_at_cursor = true,
                filetypes = { 'markdown', 'vimwiki', 'quarto' },
              },
            },
            editor_only_render_when_focused = false,
            window_overlap_clear_enabled = true,
            -- window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', 'scrollview' },
            tmux_show_only_in_active_window = true,
            window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', 'scrollview', 'scrollview_sign' },
            max_width = nil,
            max_height = nil,
            max_width_window_percentage = nil,
            max_height_window_percentage = 30,
            kitty_method = 'normal',
          }

          local function clear_all_images()
            local bufnr = vim.api.nvim_get_current_buf()
            local images = image.get_images { buffer = bufnr }
            for _, img in ipairs(images) do
              img:clear()
            end
          end

          local function get_image_at_cursor(buf)
            local images = image.get_images { buffer = buf }
            local row = vim.api.nvim_win_get_cursor(0)[1] - 1
            for _, img in ipairs(images) do
              if img.geometry ~= nil and img.geometry.y == row then
                local og_max_height = img.global_state.options.max_height_window_percentage
                img.global_state.options.max_height_window_percentage = nil
                return img, og_max_height
              end
            end
            return nil
          end

          local create_preview_window = function(img, og_max_height)
            local buf = vim.api.nvim_create_buf(false, true)
            local win_width = vim.api.nvim_get_option_value('columns', {})
            local win_height = vim.api.nvim_get_option_value('lines', {})
            local win = vim.api.nvim_open_win(buf, true, {
              relative = 'editor',
              style = 'minimal',
              width = win_width,
              height = win_height,
              row = 0,
              col = 0,
              zindex = 1000,
            })
            vim.keymap.set('n', 'q', function()
              vim.api.nvim_win_close(win, true)
              img.global_state.options.max_height_window_percentage = og_max_height
            end, { buffer = buf })
            return { buf = buf, win = win }
          end

          local handle_zoom = function(bufnr)
            local img, og_max_height = get_image_at_cursor(bufnr)
            if img == nil then
              return
            end

            local preview = create_preview_window(img, og_max_height)
            image.hijack_buffer(img.path, preview.win, preview.buf)
          end

          vim.keymap.set('n', '<leader>io', function()
            local bufnr = vim.api.nvim_get_current_buf()
            handle_zoom(bufnr)
          end, { buffer = true, desc = 'image [o]pen' })

          vim.keymap.set('n', '<leader>ic', clear_all_images, { buffer = true, desc = 'image [c]lear' })
        end,
      },
}

