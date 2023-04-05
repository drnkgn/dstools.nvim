local util = require("DSTools.util")

local M = {}

function M.setup()
    vim.b.ds_cache = util.load_cache(
        util.generate_default_filename()
    ) or {
        legislations = {},
        cases = {},
    }
    require("DSTools.commands").create_commands()
end

return M
