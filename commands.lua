local dstools = require("DSTools.main")
local telescope = require("DSTools.telescope")
local utils = require("DSTools.utils")

local M = {}

M.create_commands = function()
    vim.api.nvim_create_user_command("DSStoreCache", function(opts)
        utils.store_cache(
            (opts.args == "" and utils.generate_default_filename())
                or opts.args
        )
    end, { nargs = "?" })

    vim.api.nvim_create_user_command("DSAddCase", function()
        local parsed_case = dstools.parse_case(
            utils.get_visual_selection().content
        )
        local case_name = parsed_case.name
        local case_citations = {}
        local case_include = false
        local case_local = false
        for _,citation in ipairs(parsed_case.citations) do
            table.insert(case_citations, dstools.parse_citation(citation))
        end

        local opt = vim.fn.input("Include? (y/n): ")
        if opt:lower() == "y" then
            case_include = true
        end
        opt = vim.fn.input("Local? (y/n): ")
        if opt:lower() == "y" then
            case_local = true
        end
        dstools.add_case(case_name, case_citations, case_local, case_include)
    end, { range = "%" })

    vim.api.nvim_create_user_command("DSAddCaseManual", function()
        local case_name = vim.fn.input("Case name: ")
        local case_citations = {}
        local case_include = false
        local case_local = false
        local citation = ""
        local idx = 1
        while true do
            citation = vim.fn.input(string.format(
                "Citation %d:",
                idx
            ))
            if citation == "" then
                break
            end
            case_citations[#case_citations+1] = citation
            idx = idx + 1
        end
        local opt = vim.fn.input("Include? (y/n): ")
        if opt:lower() == "y" then
            case_include = true
        end
        opt = vim.fn.input("Local? (y/n): ")
        if opt:lower() == "y" then
            case_local = true
        end
        dstools.add_case(case_name, case_citations, case_local, case_include)
    end, {})

    vim.api.nvim_create_user_command(
        "DSSearchCases",
        telescope.search_case,
        {}
    )
end

return M
