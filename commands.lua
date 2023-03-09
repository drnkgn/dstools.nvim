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

    vim.api.nvim_create_user_command("DSReload", function()
        vim.b.ds_cache = utils.load_cache(
            utils.generate_default_filename()
        ) or {
            legislations = {},
            cases = {},
        }
    end, {})

    vim.api.nvim_create_user_command("DSAddLegislation", function()
        local legis_name = vim.fn.input("Name: ")
        local legis_code = vim.fn.input("Code: ")
        local legis_section = vim.fn.input("Section: ")
        local legis_rule = vim.fn.input("Rule: ")
        local legis_include = false

        if legis_section == "" then
            legis_section = nil
        end
        if legis_rule == "" then
            legis_rule = nil
        end

        local opt = vim.fn.input("Include? (ENTER/n): ")
        if opt == "" then
            legis_include = true
        end
        dstools.add_legislation(
            legis_name,
            legis_code,
            legis_section,
            legis_rule,
            legis_include)
    end, {})

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

        local opt = vim.fn.input("Include? (ENTER/n): ")
        if opt == "" then
            case_include = true
        end
        opt = vim.fn.input("Local? (ENTER/n): ")
        if opt == "" then
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
                "Citation %d: ",
                idx
            ))
            if citation == "" then
                break
            end
            case_citations[#case_citations+1] = citation
            idx = idx + 1
        end
        local opt = vim.fn.input("Include? (ENTER/n): ")
        if opt == "" then
            case_include = true
        end
        opt = vim.fn.input("Local? (ENTER/n): ")
        if opt == "" then
            case_local = true
        end
        dstools.add_case(case_name, case_citations, case_local, case_include)
    end, {})

    vim.api.nvim_create_user_command(
        "DSSearchCases",
        telescope.search_case,
        { range = "%" }
    )

    vim.api.nvim_create_user_command(
        "DSSearchLegislations",
        telescope.search_legislation,
        { range = "%" }
    )

    vim.api.nvim_create_user_command("DSGenCaseList", function()
        -- CHORE: very unoptimized solution, restructure table may improve
        -- performance (if needed)
        local local_case = {}
        local foreign_case = {}
        local res = {}
        local sort_name_ascending = function(a, b)
            return a.name < b.name
        end
        for _,case in ipairs(vim.b.ds_cache.cases) do
            if case.include then
                if case.islocal then
                    local_case[#local_case+1] = case
                else
                    foreign_case[#foreign_case+1] = case
                end
            end
        end
        table.sort(local_case, sort_name_ascending)
        table.sort(foreign_case, sort_name_ascending)
        for _,case in ipairs(utils.merge_array(foreign_case, local_case)) do
            table.insert(
                res,
                (string.format(
                    "<p><i>%s (refd)</i></p>",
                    string.gsub(dstools.link_case(case), "<%/?i>", "")
                ))
            )
            -- insert newlines in between
            table.insert(res, "")
        end

        vim.api.nvim_put(res, "l", false, false)
    end, {})
end

return M
