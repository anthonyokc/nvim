return {
    "dmtrKovalenko/fff.nvim",
    build = "cargo build --release",
    -- or if you are using nixos
    -- build = "nix run .#release",
    opts = {
        width = 0.9,
        height = 0.9,
        prompt = "🤠 ",
        max_results = 70,

        keymaps = {
            close = { '<Esc>', '<C-c>' },
            move_up = { '<Up>', '<C-k>', '<C-p>' },
            move_down = { '<Down>', '<C-j>', '<C-n>' },
        },

        debug = {
            show_scores = false, -- Toggle with F2 or :FFFDebug
        },
    },
    keys = {
        {
            "ff",
            function()
                require("fff").find_files() -- or find_in_git_root() if you only want git files
            end,
            desc = "Open file picker",
        },
    },
}
