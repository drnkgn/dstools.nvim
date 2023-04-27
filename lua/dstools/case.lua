local cache = require("dstools.cache")
local citation = require("dstools.citation")
local util = require("dstools.util")

local M = {}

M.types = {
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
        "AMCR",
        "AMEJ",
    },
}

function M.parse(str)
    local parsed = {
        name = "",
        citations = {},
    }
    local chars = util.str2chars(str)
    local end_idx = #chars
    for idx = #chars,1,-1 do
        while string.match(chars[end_idx], "[%s%c;]") do
            end_idx = end_idx - 1
        end
        if string.match(chars[idx], "%[") then
            table.insert(
                parsed.citations, 1,
                citation.parse(
                    table.concat(vim.list_slice(chars, idx, end_idx))
                )
            )
            end_idx = idx - 1
        end
    end
    parsed.name = table.concat(vim.list_slice(chars, 1, end_idx))
    return parsed
end

function M.add(name, citations, islocal, include)
    local temp = cache.get_cache()
    table.insert(temp.cases, {
        name = name,
        citations = citations,
        include = include,
        islocal = islocal,
    })
    cache.set_cache(temp)
end

function M.link(data, content)
    content = content or data.name

    local res = ""
    if data.islocal then
        res = {string.format(
            "<LINK HREF=\"case_notes/showcase.aspx?pageid=%s;\"><i>%s</i> %s</LINK>",
            citation.pageid(data.citations[1]),
            content,
            citation.construct(data.citations[1])
        )}
        for idx = 2,#data.citations do
            if vim.tbl_contains(M.types.include, data.citations[idx].type) then
                res[#res+1] = string.format(
                    "; <LINK HREF=\"case_notes/showcase.aspx?pageid=%s;\">%s</LINK>",
                    citation.pageid(data.citations[idx]),
                    citation.construct(data.citations[idx])
                )
            else
                res[#res+1] = string.format(
                    "; %s",
                    citation.construct(data.citations[idx])
                )
            end
        end
    else
        res = { string.format("<i>%s</i> %s", content, data.citations[1]) }
        for idx = 2,#data.citations do
            res[#res+1] = string.format(
                "; %s",
                data.citations[idx]
            )
        end
    end

    return table.concat(res)
end

---@param left table: left operand
---@param right table: right operand
function M.equal(left, right)
    if left.name ~= right.name then return false end

    return true
end

return M
