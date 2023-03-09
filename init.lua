local utils = require("DSTools.utils")

local M = {}

function M.setup()
    vim.b.ds_cache = utils.load_cache(
        utils.generate_default_filename()
    ) or {
        legislations = {},
        cases = {},
    }
    require("DSTools.commands").create_commands()
end

return M
