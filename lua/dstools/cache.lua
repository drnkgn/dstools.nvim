local util = require("dstools.util")
local json = require("dstools.dependencies.json")

local M = {}

function M.get_cache()
    return vim.b[util.get_bufnr()].ds_cache or {
        legislations = {},
        cases = {},
    }
end

-- @param data table: data that will be overwritten as
function M.set_cache(data)
    vim.b[util.get_bufnr()].ds_cache = data
end

function M.store_cache(path)
    local file = io.open(path, "w")
    if file then
        file:write(json.encode(M.get_cache()))
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
