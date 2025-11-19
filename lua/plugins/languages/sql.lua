return {
    -- Core: run SQL queries from Vim/Neovim
    {
        "tpope/vim-dadbod",
        cmd = { "DB", "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    },

    -- UI for exploring DBs
    {
        "kristijanhusak/vim-dadbod-ui",
        cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
        dependencies = {
            "tpope/vim-dadbod",
            { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
        },
        init = function()
            local data_path = vim.fn.stdpath("data")
            vim.g.db_ui_auto_execute_table_helpers = 1
            vim.g.db_ui_save_location = data_path .. "/dadbod_ui"
            vim.g.db_ui_tmp_query_location = data_path .. "/dadbod_ui/tmp"
            vim.g.db_ui_show_database_icon = true
            vim.g.db_ui_use_nerd_fonts = true
            vim.g.db_ui_use_nvim_notify = true
            vim.g.db_ui_execute_on_save = false

            local group = vim.api.nvim_create_augroup("DadbodUIWindowSizing", { clear = true })
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "dbout",
                group = group,
                callback = function(args)
                    local editor_height = vim.o.lines - vim.o.cmdheight
                    local target = math.max(5, math.floor(editor_height * 0.4))
                    local win = vim.api.nvim_get_current_win()
                    if vim.api.nvim_win_is_valid(win) then
                        vim.api.nvim_win_set_height(win, target)
                    end
                end,
            })
        end,
    },

    -- Completion source powered by vim-dadbod
    {
        "kristijanhusak/vim-dadbod-completion",
        dependencies = { "tpope/vim-dadbod" },
        ft = { "sql", "mysql", "plsql" },
    },

    -- Provides database access to many dbms
    {
        "vim-scripts/dbext.vim",
        ft = { "sql", "mysql", "plsql" },
    }
}
