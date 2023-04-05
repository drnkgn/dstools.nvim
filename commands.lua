local case = require("DSTools.case")
local legislation = require("DSTools.legislation")
local util = require("DSTools.util")
local telescope = require("DSTools.telescope")

local M = {}

M.create_commands = function()
    vim.api.nvim_create_user_command("DSStoreCache", function(opts)
        util.store_cache(
            (opts.args == "" and util.generate_default_filename())
                or opts.args
        )
    end, { nargs = "?" })

    vim.api.nvim_create_user_command("DSReload", function()
        vim.b.ds_cache = util.load_cache(
            util.generate_default_filename()
        ) or {
            legislations = {},
            cases = {},
        }
    end, {})

    vim.api.nvim_create_user_command("DSAddLegislation", function()
        local name = vim.fn.input("Name: ")
        local code = vim.fn.input("Code: ")
        local section = vim.fn.input("Section: ")
        local rule = vim.fn.input("Rule: ")
        local include = false

        -- set redundant variables to nil
        -- required due to how linking was implemented
        if section == "" then section = nil end
        if rule == "" then rule = nil end

        local input = vim.fn.input("Include? (ENTER/n): ")
        if input == "" then
            include = true
        end
        legislation.add(
            name,
            code,
            section,
            rule,
            include)
    end, {})

    vim.api.nvim_create_user_command("DSAddCase", function()
        local parsed = case.parse(
            util.get_visual_selection().content
        )
        local name = parsed.name
        local citations = {}
        local include = false
        local islocal = false
        for i,v in ipairs(parsed.citations) do
            citations[#citations+1] = citation.parse(v)
        end

        local input = vim.fn.input("Include? (ENTER/n): ")
        if input == "" then
            include = true
        end
        input = vim.fn.input("Local? (ENTER/n): ")
        if input == "" then
            islocal = true
        end
        case.add(name, citations, islocal, include)
    end, { range = "%" })

    vim.api.nvim_create_user_command("DSAddCaseManual", function()
        local name = vim.fn.input("Case name: ")
        local citations = {}
        local include = false
        local islocal = false

        local input = ""
        local idx = 1
        while true do
            input = vim.fn.input(string.format("Citation %d: ", idx))
            if input == "" then break end
            citations[#citations+1] = input
            idx = idx + 1
        end
        input = vim.fn.input("Include? (ENTER/n): ")
        if input == "" then
            include = true
        end
        input = vim.fn.input("Local? (ENTER/n): ")
        if input == "" then
            islocal = true
        end
        case.add(name, citations, islocal, include)
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
        local cases = {}
        local res = {}
        local sort_name_ascending = function(a, b)
            return a.name < b.name
        end
        for i,v in ipairs(vim.b.ds_cache.cases) do
            if v.include then
                cases[#cases+1] = v
            end
        end
        table.sort(cases, sort_name_ascending)
        for i,v in ipairs(cases) do
            table.insert(
                res,
                (string.format(
                    "<p><i>%s (refd)</i></p>",
                    string.gsub(case.link(v), "<%/?i>", "")
                ))
            )
            table.insert(res, "")
        end

        vim.api.nvim_put(res, "l", false, false)
    end, {})
end

return M
