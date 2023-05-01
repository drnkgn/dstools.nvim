local case = require("dstools.case")
local citation = require("dstools.citation")
local legislation = require("dstools.legislation")
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
        data = json.decode(file:read("*all"))
        io.close(file)

        for i,v in ipairs(data.cases) do
            if v.islocal then
                for j,w in ipairs(v.citations) do
                    v.citations[j] = citation.new(
                        w.type, w.year, w.vol, w.page
                    )
                end
            end
            data.cases[i] = case.new(v.name, v.citations, v.islocal, v.include)
        end

        for i,v in ipairs(data.legislations) do
            data.legislations[i] = legislation.new(
                v.name, v.code, v.section, v.rule, v.include
            )
        end

        return data
    end
    return nil
end

return M
