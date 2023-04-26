local M = {}

function M.add(name, code, section, rule, include)
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

function M.link(legislation, content)
    content = content or legislation.name

    local link = ""
    local code = legislation.code
    local section = ""
    local rule = ""
    if legislation.section then
        link = "legislationSectiondisplayed.aspx?"

        code = code .. ";"

        if legislation.rule then
            rule = "SN" .. legislation.rule .. "."
            section = (legislation.section and legislation.section .. ";") or ""
        else
            section = legislation.section .. "."
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
