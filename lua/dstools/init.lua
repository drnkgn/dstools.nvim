local cache = require("dstools.cache")
local util = require("dstools.util")

local M = {}

function M.setup()
    vim.b[util.get_bufnr()].ds_cache = cache.load_cache(
        util.generate_default_filename()
    )
    require("dstools.commands").create_commands()
end

return M
