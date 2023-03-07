local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local M = {}

M.search_case = function(opts)
    local displayer = entry_display.create({
        separator = "",
        items = {
            { width = 3 },
            { remaining = true },
        },
    })
    local make_display = function(entry)
        local tick_box = "☐"
        if entry.value.include then
            tick_box = "☒"
        end
        return displayer({
            tick_box,
            entry.value.name,
        })
    end
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Cases",
        finder = finders.new_table {
            results = vim.b.ds_cache.cases,
            entry_maker = function(entry)
                return {
                    value = entry,
                    display = make_display,
                    ordinal = entry.name,
                }
            end,
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                -- TODO: link case
            end)
            return true
        end,
    }):find()
end

return M
