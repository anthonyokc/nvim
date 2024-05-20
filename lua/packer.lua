  use {
        'nvim-telescope/telescope.nvim', tag = '0.1.6',
        -- or                            , branch = '0.1.x',
        requires = { {'nvim-lua/plenary.nvim'} }
  }

  use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
  }

  use 'mbbill/undotree'

  use 'tpope/vim-fugitive'

  use 'ThePrimeagen/vim-with-me'

  use 'eandrju/cellular-automaton.nvim'

  use 'nvim-tree/nvim-web-devicons' -- Adds various dev nerdfont type icons

  use 'jidn/vim-dbml'

  -- Powertoys like window
  use {
  'nvim-lualine/lualine.nvim',
  requires = { 'nvim-tree/nvim-web-devicons', opt = true }
}

  use {
  'VonHeikemen/lsp-zero.nvim',
  branch = 'v3.x',
  requires = {
    --- Uncomment the two plugins below if you want to manage the language servers from neovim
    {'williamboman/mason.nvim'},
    {'williamboman/mason-lspconfig.nvim'},

    {'neovim/nvim-lspconfig'},
    {'hrsh7th/nvim-cmp'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'L3MON4D3/LuaSnip'},
  }}

  use 'jalvesaq/Nvim-R'
  use 'w0rp/ale'

  use 'github/copilot.vim'
