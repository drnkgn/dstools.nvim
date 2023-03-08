local utils = require("DSTools.utils")

local M = {}

local make_citation = function(citation)
    local vol = citation.vol or ""
    if citation.vol then
        vol = vol .. " "
    end
    return string.format(
        "[%s] %s%s %s",
        citation.year,
        vol,
        citation.type,
        citation.page
    )
end

local case_tag_attribute = function(citation)
    local vol = citation.vol or ""
    if citation.vol then
        vol = vol .. "_"
    end
    return string.format(
        "HREF=\"case_notes/showcase.aspx?pageid=%s_%s%s_%s;\"",
        citation.type,
        vol,
        citation.year,
        citation.page
    )
end

M.case_type = {
    include = {
        "SSLR",
        "MELR",
        "MELRU",
        "MLRA",
        "MLRAU",
        "MLRH",
        "MLRHU",
    },
    exclude = {
        "LNS",
        "MLJU",
    },
}

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
                1,
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

M.add_legislation = function(name, code, section, rule, include)
    local temp = vim.b.ds_cache or {}
    table.insert(temp.legislations, {
        name = name,
        code = code,
        section = section,
        rule = rule,
        include = include,
    })
    vim.b.ds_cache = temp
end

M.link_case = function(case)
    local res = utils.add_tag(case.name, "i")

    if case.islocal then
        res = res .. " " .. make_citation(case.citations[1])
        res = utils.add_tag(
            res,
            "LINK",
            case_tag_attribute(case.citations[1])
        )
        for idx = 2,#case.citations do
            res = res .. "; "
            if vim.tbl_contains(
                M.case_type.include,
                case.citations[idx].type
            ) then
                res = res .. utils.add_tag(
                    make_citation(case.citations[idx]),
                    "LINK",
                    case_tag_attribute(case.citations[idx])
                )
            elseif not vim.tbl_contains(
                M.case_type.exclude,
                case.citations[idx]
            ) then
                res = res .. make_citation(case.citations[idx])
            end
        end
    else
        res = res .. " " .. case.citations[1]
        for idx = 2,#case.citations do
            res = res .. "; " .. case.citations[idx]
        end
    end

    return res
end

return M
