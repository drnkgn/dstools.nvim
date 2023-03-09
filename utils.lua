local json = require("DSTools.json")

local M = {}

function M.generate_default_filename()
    -- TODO: probably a good idea to support relative path as well
    return string.format(
        "TEMP_%s",
        string.gsub(
            vim.fn.expand("%:t"),
            "xml",
            "json"
        )
    )
end

function M.str2chars(str)
    local t = {}
    for c in str:gmatch(".") do
        t[#t+1] = c
    end
    return t
end

function M.merge_array(arr1, arr2)
    -- TODO: probably should support more than two arrays
    for _,e in ipairs(arr2) do
        arr1[#arr1+1] = e
    end
    return arr1
end

function M.store_cache(path)
    local file = io.open(path, "w")
    if file then
        file:write(json.encode(vim.b.ds_cache or {
            legislation = {},
            cases = {},
        }))
        io.close(file)
    end
end

function M.load_cache(path)
    local lines = {}
    local file = io.open(path, "r")
    if file then
        for line in file:lines() do
            lines[#lines+1] = line
        end
        io.close(file)
        return json.decode(table.concat(lines))
    end
    return nil
end

function M.add_tag(content, tag, attribute)
    -- TODO: support multiple attributes?
    attribute = attribute
    if attribute then
        attribute = " " .. attribute
    else
        attribute = ""
    end
    return string.format(
        "<%s%s>%s</%s>",
        tag,
        attribute,
        content,
        tag
    )
end

function M.get_visual_selection()
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")
    local n_lines = math.abs(end_pos[2] - start_pos[2]) + 1
    local lines = vim.api.nvim_buf_get_lines(
        0,
        start_pos[2] - 1,
        end_pos[2],
        false
    )
    lines[1] = string.sub(lines[1], start_pos[3], -1)
    if n_lines == 1 then
        lines[n_lines] = string.sub(
            lines[n_lines],
            1,
            end_pos[3] - start_pos[3] + 1
        )
    else
        lines[n_lines] = string.sub(lines[n_lines], 1, end_pos[3])
    end
    return {
        start_pos = start_pos,
        end_pos = end_pos,
        content = table.concat(lines, '\n'),
    }
end

return M
