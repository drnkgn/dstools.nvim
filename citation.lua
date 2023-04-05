local M = {}

function M.parse(str)
    local parsed = {
        year = nil,
        vol = nil,
        type = nil,
        page = nil,
    }
    local tokens = vim.split(str, " ")
    parsed.year = string.match(tokens[1], "%d+")
    parsed.page = tokens[#tokens]
    for idx = 2,#tokens-1 do
        if string.match(tokens[idx], "[%(%)A-Z]+") then
            if not parsed.type then
                parsed.type = tokens[idx]
            else
                parsed.type = (
                    parsed.type ..
                    " " ..
                    tokens[idx]
                )
            end
        else
            parsed.vol = tokens[idx]
        end
    end
    return parsed
end

function M.construct(citation)
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

function M.pageid(citation)
    local vol = citation.vol or ""
    if citation.vol then
        vol = vol .. "_"
    end
    return string.format(
        "%s_%s_%s%s",
        citation.type,
        citation.year,
        vol,
        citation.page
    )
end

return M
