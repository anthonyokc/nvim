return {
    "pasky/claude.vim",
    config = function()
        -- Set the API key for Claude from environment variable
        vim.g.claude_api_key = os.getenv("ANTHROPIC_NVIM_API_KEY")

        -- Function to define keymap options
        local function keymapOptions()
            return {
                noremap = true, -- Non-recursive mapping
                silent = true,  -- Do not show command in command-line
                nowait = true   -- Do not wait for more key sequences
            }
        end

        -- Key mappings for Claude commands
        vim.keymap.set({ "n", "v" }, "<leader>Cc", "<cmd>ClaudeChat<cr>", keymapOptions())      -- Start a chat with Claude
        vim.keymap.set({ "n", "v" }, "<leader>Ci", "<cmd>ClaudeImplement<cr>", keymapOptions()) -- Implement code with Claude
        vim.keymap.set({ "n", "v" }, "<leader>Cs", "<cmd>ClaudeSend<cr>", keymapOptions())      -- Send message to Claude
        vim.keymap.set({ "n", "v" }, "<leader>Cx", "<cmd>ClaudeCancel<cr>", keymapOptions())    -- Cancel Claude command
    end
}
