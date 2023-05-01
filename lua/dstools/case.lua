local source = require("dstools.source")
local citation = require("dstools.citation")
local util = require("dstools.util")

local M = {}
M.__index = M

function M.__eq(a, b)
    if a.name ~= b.name then return false end

    return true
end

function M.new(name, citations, islocal, include)
    local instance = setmetatable({}, M)
    instance.name      = name or ""
    instance.citations = citations or {}
    instance.islocal   = util.ifnil(islocal, true)
    instance.include   = util.ifnil(include, true)
    return instance
end

function M:parse(str)
    local chars = util.str2chars(str)
    local end_idx = #chars
    for idx = #chars,1,-1 do
        while string.match(chars[end_idx], "[%s%c;]") do
            end_idx = end_idx - 1
        end
        if string.match(chars[idx], "%[") then
            local new_citation = citation.new()
            new_citation:parse(
                table.concat(vim.list_slice(chars, idx, end_idx))
            )
            table.insert(self.citations, 1, new_citation)
            end_idx = idx - 1
        end
    end
    self.name = table.concat(vim.list_slice(chars, 1, end_idx))
end

function M:update(name, citations, islocal, include)
    self.name      = name or self.name
    self.citations = citations or self.citations
    self.islocal   = util.ifnil(islocal, self.islocal)
    self.include   = util.ifnil(include, self.include)
end

function M:link()
    local res = ""
    if self.islocal then
        res = {string.format(
            "<LINK HREF=\"case_notes/showcase.aspx?pageid=%s;\"><i>%s</i> %s</LINK>",
            self.citations[1]:format("pageid"),
            self.name,
            self.citations[1]:format("citation")
        )}
        for idx = 2,#self.citations do
            if vim.tbl_contains(source.types.include, self.citations[idx].type) then
                res[#res+1] = string.format(
                    "; <LINK HREF=\"case_notes/showcase.aspx?pageid=%s;\">%s</LINK>",
                    self.citations[idx]:format("pageid"),
                    self.citations[idx]:format("citation")
                )
            else
                res[#res+1] = string.format(
                    "; %s",
                    self.citations[idx]:format("citation")
                )
            end
        end
    else
        res = { string.format("<i>%s</i> %s", self.name, self.citations[1]) }
        for idx = 2,#self.citations do
            res[#res+1] = string.format(
                "; %s",
                self.citations[idx]
            )
        end
    end

    return table.concat(res)
end

return M
