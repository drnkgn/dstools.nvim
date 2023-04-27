if vim.g.loaded_dstools then
    return
end
vim.g.loaded_dstools = true

local file_exists = require("dstools.util").file_exists

if file_exists(".dsconf") then
    local dstools = vim.api.nvim_create_augroup("dstools", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = dstools,
        pattern = "xml",
        callback = function()
            -- The number of the buffer in which `dstools` is active
            -- Used to access `vim.b.ds_cache` from other buffers when needed
            vim.g.dsbufnr = vim.api.nvim_win_get_buf(0)

            require("dstools").setup()

            vim.api.nvim_create_autocmd("ExitPre", {
                group = dstools,
                pattern = "*.xml",
                callback = function()
                    vim.api.nvim_command("DSStoreCache")
                end
            })
        end
    })
end
