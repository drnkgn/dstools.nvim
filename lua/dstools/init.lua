local util = require("dstools.util")

local M = {}

function M.setup()
    vim.b.ds_cache = util.load_cache(
        util.generate_default_filename()
    ) or {
        legislations = {},
        cases = {},
    }
    require("dstools.commands").create_commands()
end

return M
