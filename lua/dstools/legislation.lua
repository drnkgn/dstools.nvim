local util = require("dstools.util")

local M = {}
M.__index = M

function M.__eq(a, b)
    if a.name ~= b.name then return false end
    if a.code ~= b.code then return false end
    if a.section ~= b.section then return false end
    if a.rule ~= b.rule then return false end

    return true
end

function M.new(name, code, section, rule, include)
    local instance = setmetatable({}, M)
    instance.name    = name or ""
    instance.code    = code or ""
    instance.section = section -- section can be nil
    instance.rule    = rule    -- rule can be nil
    instance.include = util.ifnil(include, true)
    return instance
end

function M:update(name, code, section, rule, include)
    self.name    = name or self.name
    self.code    = code or self.code
    self.section = util.iff(section == "", nil, section or self.section)
    self.rule    = util.iff(rule == "", nil, rule or self.rule)
    self.include = util.ifnil(include, self.include)
end

function M:link(content)
    local link = ""
    local code = self.code
    local section = ""
    local rule = ""
    if self.section then
        link = "legislationSectiondisplayed.aspx?"

        code = code .. ";"

        if self.rule then
            rule = "SN" .. self.rule .. "."
            section = (self.section and self.section .. ";") or ""
        else
            section = self.section .. "."
        end
    else
        link = "legislationMainDisplayed.aspx?"
    end

    return string.format(
        "<LINK HREF=\"%s%s%s%s;;\">%s</LINK>",
        link,
        code,
        section,
        rule,
        content
    )
end

return M
