local M = {}

function M.setup()
    require("dstools.cache").init_cache()
    require("dstools.commands").create_commands()
end

return M
