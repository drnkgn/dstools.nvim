local util = require("dstools.util")
local json = require("dstools.dependencies.json")

local M = {}

M.cache_map = {
    "cases",
    "legislations",
}

M.internal_cache = {
    cases = {},
    legislations = {},
}

function M.init_cache()
    M.internal_cache = M.load_cache(
        util.generate_default_filename()
    ) or M.internal_cache
end

function M.get_cache()
    return M.internal_cache
end

---@param data table: data that will be overwritten as
function M.set_cache(data)
     M.internal_cache = data
end

function M.update_cache(cache, data)
    assert(
        vim.tbl_contains(M.cache_map, cache),
        string.format("Cache `%s` does not exist in `internal_cache`", cache)
    )
    table.insert(M.internal_cache[cache], data)
end

function M.store_cache(path)
    local file = io.open(path, "w")
    if file then
        file:write(json.encode(M.internal_cache))
        io.close(file)
    end
end

function M.load_cache(path)
    local lines = {}
    local file = io.open(path, "r")
    if file then
        data = file:read("*all")
        io.close(file)
        return json.decode(data)
    end
    return nil
end

return M
