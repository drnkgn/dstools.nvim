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

    vim.keymap.set("v", "<leader>dsc", ":DSSearchCases<cr>")
    vim.keymap.set("v", "<leader>dsl", ":DSSearchLegislations<cr>")
    vim.keymap.set("v", "<leader>dnc", ":DSAddCase<cr>")
    vim.keymap.set("n", "<leader>dnl", ":DSAddLegislation<cr>")
end
