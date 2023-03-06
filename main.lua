local utils = require("DSTools.utils")

local M = {}

M.parse_citation = function(str)
    local parsed_citation = {
        year = nil,
        vol = nil,
        type = nil,
        page = nil,
    }
    local tokens = vim.split(str, " ")
    parsed_citation.year = string.match(tokens[1], "%d+")
    parsed_citation.page = tokens[#tokens]
    for idx = 2,#tokens-1 do
        if string.match(tokens[idx], "[%(%)A-Z]+") then
            if not parsed_citation.type then
                parsed_citation.type = tokens[idx]
            else
                parsed_citation.type = (
                    parsed_citation.type ..
                    " " ..
                    tokens[idx]
                )
            end
        else
            parsed_citation.vol = tokens[idx]
        end
    end
    return parsed_citation
end

M.parse_case = function(str)
    local parsed_case = {
        name = "",
        citations = {},
    }
    local chars = utils.str2chars(str)
    local end_idx = #chars
    for idx = #chars,1,-1 do
        while string.match(chars[end_idx], "[%s%c;]") do
            end_idx = end_idx - 1
        end
        if string.match(chars[idx], "%[") then
            table.insert(
                parsed_case.citations,
                table.concat(vim.list_slice(chars, idx, end_idx))
            )
            end_idx = idx - 1
        end
    end
    parsed_case.name = table.concat(
        vim.list_slice(chars, 1, end_idx)
    )
    return parsed_case
end

M.add_case = function(name, citations, islocal, include)
    local temp = vim.b.ds_cache or {}
    table.insert(temp.cases, {
        name = name,
        citations = citations,
        include = include,
        islocal = islocal,
    })
    vim.b.ds_cache = temp
end

return M
