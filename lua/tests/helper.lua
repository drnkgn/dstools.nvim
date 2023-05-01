local lu = require("dstools.dependencies.luaunit")
local util = require("dstools.util")

local M = {}

--- values used during testing
M.value = {
    citation = {
        locale = {
            mlra = {
                type = "MLRA",
                year = "2010",
                vol  = "2",
                page = "293"
            },
            clj_rep = {
                type = "CLJ (Rep)",
                year = "2010",
                vol  = "2",
                page = "293"
            }
        },
        foreign = "[1982] 3 All ER 38"

    },
    legislation = {
        name = "Rules of Court 2012",
        code = "MY_PUAS_2012_205",
        section = "53",
        rule = "2",
        include = true
    },
    case = {
        locale = {
            name = "A v. B",
            citations = { {
                type = "MLRA",
                year = "2010",
                vol  = "2",
                page = "293"
            } },
            islocal = true,
            include = true
        },
        foreign = {
            name = "C v. D",
            citations = { "[1982] 3 All ER 38" },
            islocal = false,
            include = false
        }
    }
}

function M.assertCitation(actual, expected)
    expected = expected or M.value.citation.locale.mlra
    lu.assertItemsEquals(actual, expected)

    local mt = getmetatable(actual)
    lu.assertIsFunction(mt.format)
    lu.assertIsFunction(mt.new)
    lu.assertIsFunction(mt.parse)
end

function M.assertCase(islocal, actual, expected)
    expected = expected or util.iff(
        islocal,
        M.value.case.locale,
        M.value.case.foreign
    )
    lu.assertItemsEquals(actual, expected)

    local mt = getmetatable(actual)
    lu.assertIsFunction(mt.__eq)
    lu.assertIsFunction(mt.link)
    lu.assertIsFunction(mt.new)
    lu.assertIsFunction(mt.parse)
    lu.assertIsFunction(mt.update)
end

function M.assertLegislation(actual, expected)
    expected = expected or M.value.legislation
    lu.assertItemsEquals(actual, expected)

    local mt = getmetatable(actual)
    lu.assertIsFunction(mt.__eq)
    lu.assertIsFunction(mt.link)
    lu.assertIsFunction(mt.new)
    lu.assertIsFunction(mt.update)
end

return M
