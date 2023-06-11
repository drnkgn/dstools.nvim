local cache = require("dstools.cache")
local case = require("dstools.case")
local citation = require("dstools.citation")
local legislation = require("dstools.legislation")
local util = require("dstools.util")
local telescope = require("dstools.telescope")

local M = {}

M.create_commands = function()
    vim.api.nvim_create_user_command("DSStoreCache", function(opts)
        cache.store_cache(
            (opts.args == "" and util.generate_default_filename())
                or opts.args
        )
    end, { nargs = "?" })

    vim.api.nvim_create_user_command("DSReload", function()
        cache.set_cache(cache.load_cache(util.generate_default_filename()))
    end, {})

    vim.api.nvim_create_user_command("DSAddLegislation", function()
        local name = vim.fn.input("Name: ")
        local code = vim.fn.input("Code: ")
        local section = vim.fn.input("Section: ")
        local rule = vim.fn.input("Rule: ")
        local include = false

        local input = vim.fn.input("Include? (ENTER/n): ")
        if input == "" then
            include = true
        end

        cache.update_cache(
            "legislations",
            legislation.new(name, code, section, rule, include)
        )
    end, {})

    vim.api.nvim_create_user_command("DSAddCase", function()
        local visual_select = util.get_visual_selection()
        local new_case = case.new()

        local input = vim.fn.input("Include? (ENTER/n): ")
        local include = util.iff(input == "", true, false)

        new_case:parse(visual_select.content)
        new_case:update(nil, nil, true, include)
        cache.update_cache("cases", new_case)

        vim.api.nvim_buf_set_text(
            0,
            visual_select.start_pos[2] - 1,
            visual_select.start_pos[3] - 1,
            visual_select.end_pos[2] - 1,
            visual_select.end_pos[3],
            { new_case:link() }
        )
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

        cache.update_cache(
            "cases",
            case.new(name, citations, islocal, include)
        )
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
        for i,v in ipairs(cache.get_cache().cases) do
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
