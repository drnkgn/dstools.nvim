local cache = require("dstools.cache")
local util = require("dstools.util")

local M = {}

function M.setup()
    require("dstools.commands").create_commands()
end

return M
