-- Filetypes where nvim-ufo should stay off (dadbod UI/queries)
local dadbod_filetypes = { 'dbui', 'dbout', 'sql', 'psql' }
local disabled_ft = {}
for _, ft in ipairs(dadbod_filetypes) do
    disabled_ft[ft] = true
end

return {
    {
        'kevinhwang91/nvim-ufo',
        event = 'BufReadPost',
        dependencies = 'kevinhwang91/promise-async',
        init = function()
            -- Autocmd to disable ufo in dadbod-related filetypes
            local group = vim.api.nvim_create_augroup('DisableUfoForDadbodUI', { clear = true })
            vim.api.nvim_create_autocmd('FileType', {
                pattern = dadbod_filetypes,
                group = group,
                callback = function(args)
                    -- Detach ufo to avoid conflicting visuals inside dadbod buffers
                    local ok, ufo = pcall(require, 'ufo')
                    if ok and disabled_ft[vim.bo[args.buf].filetype] then
                        ufo.detach(args.buf)
                    end
                end,
            })
        end,
        config = function()
            -- Global defaults so regular buffers get modern folding by default
            vim.opt.foldcolumn = '1'
            vim.opt.foldlevel = 99
            vim.opt.foldlevelstart = 99
            vim.opt.foldenable = true

            local ufo = require('ufo')
            ufo.setup({
                provider_selector = function(_, filetype)
                    -- Return empty selector to keep ufo off for dadbod filetypes
                    if disabled_ft[filetype] then
                        return ''
                    end

                    return { 'treesitter', 'indent' }
                end,
            })
        end,
    }
}
