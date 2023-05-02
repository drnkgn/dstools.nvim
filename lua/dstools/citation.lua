local M = {}
M.__index = M

function M.new(type, year, vol, page)
    local instance = setmetatable({}, M)
    instance.type = type
    instance.year = year
    instance.vol  = vol
    instance.page = page
    return instance
end

function M:parse(str)
    local tokens = vim.split(str, " ")
    self.year = string.match(tokens[1], "%d+")
    self.page = tokens[#tokens]
    for idx = 2,#tokens-1 do
        if string.match(tokens[idx], "[%(%)A-Z]+") then
            if not self.type then
                self.type = tokens[idx]
            else
                self.type = (self.type .. " " .. tokens[idx])
            end
        else
            self.vol = tokens[idx]
        end
    end
end

--- Format citation based on `style`
--- @param style string: "citation" => [YEAR] VOL TYPE PAGE
---                      "pageid"   => TYPE_YEAR_VOL_PAGE
function M:format(style)
    local vol = self.vol or ""

    if style == "citation" then
        if self.vol then
            vol = vol .. " "
        end
        return string.format(
            "[%s] %s%s %s",
            self.year,
            vol,
            self.type,
            self.page
        )
    elseif style == "pageid" then
        if self.vol then
            vol = vol .. "_"
        end
        return string.format(
            "%s_%s_%s%s",
            self.type,
            self.year,
            vol,
            self.page
        )
    else
        assert(false, "Invalid citation format style")
    end
end

return M
