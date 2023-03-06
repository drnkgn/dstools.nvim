local M = {}

M.setup = function()
    if not vim.b.ds_cache then
        vim.b.ds_cache = {
            legislations = {},
            cases = {},
        }
    end
    require("DSTools.commands").create_commands()
end

return M
