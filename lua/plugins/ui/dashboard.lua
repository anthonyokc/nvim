return {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
        require('dashboard').setup {
            -- config
            shortcut_type = 'number',
            config = {
                week_header = {
                    enable = true,
                },
                shortcut = {
                    {
                        icon = ' ',
                        icon_hl = '@variable',
                        desc = 'Files',
                        group = 'Label',
                        action = 'Telescope find_files',
                        key = 'f',
                    },
                },
                project = { enable = false },
                footer = {
                    '',
                    '“The least advantaged are not, if all goes well, the unfortunate and unlucky,',
                    'objects of our charity and compassion, much less our pity,',
                    'but those to whom reciprocity is owed as a matter of basic justice.”',
                    '-John Rawls (JF, 139).'
                },
            }
        }
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } }
}
