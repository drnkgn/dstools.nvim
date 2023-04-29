local M = {}

end

function M.file_exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

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
