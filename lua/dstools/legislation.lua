local cache = require("dstools.cache")

local M = {}

function M.add(name, code, section, rule, include)
    local temp = cache.get_cache()
    table.insert(temp.legislations, {
        name = name,
        code = code,
        section = section,
        rule = rule,
        include = include,
    })
    cache.set_cache(temp)
end

function M.link(data, content)
    content = content or data.name

    local link = ""
    local code = data.code
    local section = ""
    local rule = ""
    if data.section then
        link = "legislationSectiondisplayed.aspx?"

        code = code .. ";"

        if data.rule then
            rule = "SN" .. legislation.rule .. "."
            section = (data.section and data.section .. ";") or ""
        else
            section = data.section .. "."
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

---@param left table: left operand
---@param right table: right operand
function M.equal(left, right)
    if left.name ~= right.name then return false end
    if left.code ~= right.code then return false end
    if left.section ~= right.section then return false end
    if left.rule ~= right.rule then return false end

    return true
end

return M
