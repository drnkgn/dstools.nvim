local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local pickers = require("telescope.pickers")
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local conf = require("telescope.config").values

local cache = require("dstools.cache")
local case = require("dstools.case")
local legislation = require("dstools.legislation")
local util = require("dstools.util")

local icon_map = {
    tick = "☒",
    untick = "☐",
}

local M = {}

---@param state bool: toggle state
---@param bufnr number: buffer number of the 'result' window
---@param picker picker: picker table
function M.toggle_include(state, bufnr, picker)
    local row = picker:get_selection_row()
    local pre = "  " .. (not state and icon_map.tick or icon_map.untick) .. " "
    -- change the icon only
    vim.api.nvim_buf_set_text(bufnr, row, 0, row, #pre, { pre })
end

---@param type string: acceptable value => {legislations, cases}
---@param bufnr number: buffer number of the 'result' window
---@param picker picker: picker table
function M.toggle_replace_func(type, bufnr, picker)
    local types = {
        "legislations",
        "cases",
    }
    assert(vim.tbl_contains(types, type), "Unknown `type` in `toggle_replace_func`")
    return function()
        local selection = action_state.get_selected_entry()
        local temp = cache.get_cache()
        for i,v in ipairs(temp[type]) do
            if selection.value == v then
                M.toggle_include(temp[type][i].include, bufnr - 2, picker)
                temp[type][i].include = not temp[type][i].include
            end
        end
        cache.set_cache(temp)
    end
end

function M.search_case(opts)
    local displayer = entry_display.create({
        separator = "",
        items = {
            { width = 3 },
            { remaining = true },
        },
    })
    local make_display = function(entry)
        return displayer({
            entry.value.include and icon_map.tick or icon_map.untick,
            entry.value.name,
        })
    end
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Cases",
        finder = finders.new_table {
            results = cache.get_cache().cases,
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
            local picker = action_state.get_current_picker(prompt_bufnr)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local visual_select = util.get_visual_selection()
                -- CHORE: probably shouldn't replace everything
                vim.api.nvim_buf_set_text(
                    0,
                    visual_select.start_pos[2] - 1,
                    visual_select.start_pos[3] - 1,
                    visual_select.end_pos[2] - 1,
                    visual_select.end_pos[3],
                    { selection.value:link() }
                )
            end)
            actions.toggle_selection:replace(
                M.toggle_replace_func("cases", prompt_bufnr, picker)
            )
            return true
        end,
    }):find()
end

function M.search_legislation(opts)
    local displayer = entry_display.create({
        separator = "",
        items = {
            { width = 3 },
            { width = 5 },
            { width = 5 },
            { remaining = true },
        },
    })
    local make_display = function(entry)
        local section = entry.value.section or ""
        local rule = entry.value.rule or ""
        return displayer({
            entry.value.include and icon_map.tick or icon_map.untick,
            section,
            rule,
            entry.value.name,
        })
    end
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Legislations",
        finder = finders.new_table {
            results = cache.get_cache().legislations,
            entry_maker = function(entry)
                local section = entry.section or ""
                local rule = entry.rule or ""
                return {
                    value = entry,
                    display = make_display,
                    ordinal = section .. rule .. entry.name,
                }
            end,
        },
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            local picker = action_state.get_current_picker(prompt_bufnr)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local visual_select = util.get_visual_selection()
                vim.api.nvim_buf_set_text(
                    0,
                    visual_select.start_pos[2] - 1,
                    visual_select.start_pos[3] - 1,
                    visual_select.end_pos[2] - 1,
                    visual_select.end_pos[3],
                    { selection.value:link(visual_select.content) }
                )
            end)
            actions.toggle_selection:replace(
                M.toggle_replace_func("legislations", prompt_bufnr, picker)
            )
            return true
        end,
    }):find()
end

return M
