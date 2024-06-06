return {
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        name = "harpoon",
        priority = 100,
        config = function()
            -- REQUIRED
            local harpoon = require("harpoon")
            harpoon:setup()
            -- REQUIRED

            function Harpoon_files()
                local contents = {}
                local marks_length = harpoon:list():length()
                local current_file_path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.")
                for index = 1, marks_length do
                    local harpoon_file_path = harpoon:list():get(index).value
                    local file_name = harpoon_file_path == "" and "(empty)" or vim.fn.fnamemodify(harpoon_file_path, ':t')

                    if current_file_path == harpoon_file_path then
                        contents[index] = string.format("%%#HarpoonNumberActive# [%s] %%#HarpoonActive#%s ", index, file_name)
                    else
                        contents[index] = string.format("%%#HarpoonNumberInactive# %s %%#HarpoonInactive#%s ", index, file_name)
                    end
                end

                return table.concat(contents)
            end

            vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
            vim.keymap.set("n", "<C-f>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

            vim.keymap.set("n", "<C-j>", function() harpoon:list():select(1) end)
            vim.keymap.set("n", "<C-k>", function() harpoon:list():select(2) end)
            vim.keymap.set("n", "<C-l>", function() harpoon:list():select(3) end)
            vim.keymap.set("n", "<C-e>", function() harpoon:list():select(4) end)
            vim.keymap.set("n", "<leader><C-j>", function() harpoon:list():replace_at(1) end)
            vim.keymap.set("n", "<leader><C-k>", function() harpoon:list():replace_at(2) end)
            vim.keymap.set("n", "<leader><C-l>", function() harpoon:list():replace_at(3) end)
            vim.keymap.set("n", "<leader><C-e>", function() harpoon:list():replace_at(4) end)

            -- Toggle previous & next buffers stored within Harpoon list
            vim.keymap.set("n", "<C-S-P>", function() harpoon:list():prev() end)
            vim.keymap.set("n", "<C-S-N>", function() harpoon:list():next() end)
        end
    },
}
