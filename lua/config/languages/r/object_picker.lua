local M = {}

local levels = vim.log.levels
local highlights_defined = false

local function is_utf8_locale()
    local env = string.lower(
        tostring(vim.env.LC_MESSAGES) .. tostring(vim.env.LC_ALL) .. tostring(vim.env.LANG)
    )
    if env:find("utf-8", 1, true) or env:find("utf8", 1, true) then return true end
    return false
end

local function add_backticks(word, esc_reserved)
    if word:find("^%[%[") then return word end

    local punct = {
        "!",
        "'",
        '"',
        "#",
        "%%",
        "&",
        "%(",
        "%)",
        "%*",
        "%+",
        ",",
        "-",
        "/",
        "\\",
        ":",
        ";",
        "<",
        "=",
        ">",
        "?",
        "@",
        "%[",
        "/",
        "%]",
        "%^",
        "%$",
        "%{",
        "|",
        "%}",
        "~",
    }

    local reserved = {
        "if",
        "else",
        "repeat",
        "while",
        "function",
        "for",
        "in",
        "next",
        "break",
        "TRUE",
        "FALSE",
        "NULL",
        "Inf",
        "NaN",
        "NA",
        "NA_integer_",
        "NA_real_",
        "NA_complex_",
        "NA_character",
    }

    local invalid_r_name = false

    if word:find(" ") or word:find("^[0-9_]") then
        invalid_r_name = true
    else
        local esc_list = {}
        vim.list_extend(esc_list, punct)
        if esc_reserved then
            for _, v in ipairs(reserved) do
                table.insert(esc_list, "^" .. v .. "$")
            end
        end
        for _, v in ipairs(esc_list) do
            if word:find(v) then
                invalid_r_name = true
                break
            end
        end
    end
    if invalid_r_name then word = "`" .. word .. "`" end
    return word
end

local function find_parent(lines, child, curline, curpos, view, is_utf8)
    local idx, parent, suffix
    while curline > 3 do
        curline = curline - 1
        local line = lines[curline]
        if not line then break end
        line = line:gsub("\r", "")
        line = line:gsub("\t.*", "")
        idx = line:find("#")
        if idx and idx < curpos then
            parent = line:sub(idx + 1):gsub("%s+$", "")
            if line:find("%[#") or line:find("%$#") then
                suffix = "$"
            elseif line:find("<#") or line:find(">#") then
                suffix = "@"
            elseif line:find(":#") then
                suffix = "::"
            else
                suffix = ""
            end
            parent = add_backticks(parent, false)
            local fullname = parent .. suffix .. child
            local spacelimit = (view == "GlobalEnv") and 6 or (is_utf8 and 12 or 8)
            if idx > spacelimit then return find_parent(lines, fullname, curline, idx, view, is_utf8) end
            return fullname
        end
    end
    return child
end

local function ensure_highlights()
    if highlights_defined then return end
    vim.api.nvim_set_hl(0, "RObjectPickerFunction", { fg = "#61afef" })
    vim.api.nvim_set_hl(0, "RObjectPickerObject", { fg = "#e5c07b" })
    highlights_defined = true
end

local function parse_entries(lines, view)
    local entries = {}
    local is_utf8 = is_utf8_locale()
    local current_pkg = nil

    for i = 3, #lines do
        local line = lines[i]
        if line and line ~= "" then
            line = line:gsub("\r", "")
            local idx = line:find("#")
            if idx then
                local type_char = line:sub(idx - 1, idx - 1)
                local segment = line:sub(idx + 1)
                local tab_pos = segment:find("\t", 1, true)
                local desc = ""
                if tab_pos then
                    desc = segment:sub(tab_pos + 1)
                    segment = segment:sub(1, tab_pos - 1)
                end
                segment = segment:gsub("%s+$", "")
                local word = add_backticks(segment, true)
                local fullname
                if idx == 5 then
                    if view == "libraries" then
                        current_pkg = word:gsub("`", "")
                        fullname = word .. ":"
                    else
                        fullname = word
                    end
                else
                    if view == "libraries" and ((is_utf8 and idx == 12) or idx == 8) then
                        fullname = word:gsub("%$%[%[", "[[")
                    elseif idx > 5 then
                        fullname = find_parent(lines, word, i, idx - 1, view, is_utf8)
                        fullname = fullname:gsub("%$%[%[", "[[")
                    else
                        fullname = word
                    end
                end

                local highlight
                if view == "GlobalEnv" then
                    if type_char == "(" or type_char == ";" then
                        highlight = "RObjectPickerFunction"
                    else
                        highlight = "RObjectPickerObject"
                    end
                end

                local display = fullname
                if desc ~= "" then display = display .. " — " .. desc end

                table.insert(entries, {
                    value = fullname,
                    display = display,
                    ordinal = fullname .. " " .. desc,
                    type_char = type_char,
                    package = current_pkg,
                    view = view,
                    description = desc,
                    highlight = highlight,
                })
            end
        end
    end

    return entries
end

local function ensure_r_ready()
    if not vim.g.R_Nvim_status or vim.g.R_Nvim_status < 7 then
        vim.notify("Start R (use :RStart) to inspect objects.", levels.WARN, { title = "R.nvim" })
        return false
    end
    if not vim.env.RNVIM_ID or vim.env.RNVIM_ID == "" then
        vim.notify("RNVIM_ID not set. Make sure R was started by R.nvim.", levels.ERROR, { title = "R.nvim" })
        return false
    end
    return true
end

local function ensure_telescope_loaded()
    local ok = pcall(require, "telescope")
    if not ok then
        local lazy_ok, lazy = pcall(require, "lazy")
        if lazy_ok then lazy.load({ plugins = { "telescope.nvim" } }) end
        ok = pcall(require, "telescope")
    end
    if not ok then
        vim.notify("telescope.nvim is required for R object search.", levels.ERROR, { title = "R.nvim" })
        return false
    end
    return true
end

local function fetch_lines(view)
    local config = require("r.config").get_config()
    local suffix = (view == "GlobalEnv") and "/globenv_" or "/liblist_"
    local path = config.localtmpdir .. suffix .. vim.env.RNVIM_ID

    local function try_read()
        if vim.fn.filereadable(path) == 0 then return nil end
        local ok, data = pcall(vim.fn.readfile, path)
        if not ok or not data or #data <= 2 then return nil end
        return data
    end

    local lines = try_read()
    if lines then return lines end

    vim.wait(800, function()
        lines = try_read()
        return lines ~= nil
    end, 40)

    return lines or {}
end

function M.run_entry_action(entry)
    if not entry or not entry.value then return end
    if not ensure_r_ready() then return end

    local type_char = entry.type_char or ""
    local view = entry.view
    local value = entry.value
    local send = require("r.send")
    local run = require("r.run")

    if type_char == "&" then
        run.send_to_nvimcom("L", value)
        return
    end

    if view == "libraries" then
        if type_char == "(" or type_char == ";" then
            local doc = require("r.doc")
            doc.ask_R_doc(value:gsub("`", ""), entry.package or "", false)
            return
        elseif type_char == ":" then
            local pkg = (entry.package or value):gsub("[:`]", "")
            if pkg ~= "" then
                local escaped = pkg:gsub('"', '\\"')
                send.cmd(string.format('help(package = "%s")', escaped))
            else
                send.cmd("help()")
            end
            return
        end
    end

    send.cmd("str(" .. value .. ")")
end

local function open_picker(view)
    if not ensure_r_ready() then return end
    if not ensure_telescope_loaded() then return end

    local job = require("r.job")
    if not job.is_running("Server") then
        vim.notify("rnvimserver job is not running.", levels.WARN, { title = "R.nvim" })
        return
    end

    local command = (view == "GlobalEnv") and "31\n" or "321\n"
    job.stdin("Server", command)

    local lines = fetch_lines(view)
    if not lines or #lines == 0 then
        vim.notify("No R objects found (" .. view .. ").", levels.INFO, { title = "R.nvim" })
        return
    end

    local entries = parse_entries(lines, view)
    if #entries == 0 then
        vim.notify("No R objects found (" .. view .. ").", levels.INFO, { title = "R.nvim" })
        return
    end

    ensure_highlights()

    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local entry_display = require("telescope.pickers.entry_display")
    local displayer = entry_display.create({
        separator = "  ",
        items = {
            { remaining = true },
            { remaining = true },
        },
    })

    pickers.new({}, {
        prompt_title = (view == "GlobalEnv") and ".GlobalEnv objects" or "R library objects",
        finder = finders.new_table({
            results = entries,
            entry_maker = function(entry)
                local desc = entry.description or ""
                return {
                    value = entry.value,
                    display = function()
                        return displayer({
                            { entry.value, entry.highlight },
                            { desc, desc ~= "" and "Comment" or nil },
                        })
                    end,
                    ordinal = entry.ordinal,
                    type_char = entry.type_char,
                    package = entry.package,
                    view = entry.view,
                    description = desc,
                    highlight = entry.highlight,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                M.run_entry_action(selection)
            end)

            local function copy_value()
                local selection = action_state.get_selected_entry()
                if selection and selection.value then
                    vim.fn.setreg('"', selection.value)
                    pcall(vim.fn.setreg, "+", selection.value)
                end
            end

            map("i", "<C-y>", copy_value)
            map("n", "y", function()
                copy_value()
                return true
            end)

            return true
        end,
    }):find()
end

function M.open_global_env()
    open_picker("GlobalEnv")
end

function M.open_library_objects()
    open_picker("libraries")
end

return M
