local lu = require("dstools.dependencies.luaunit")
local helper = require("tests.helper")

local case = require "dstools.case"

local TestCase = {}

function TestCase:TestNewWithoutParams()
    local obj = case.new()
    helper.assertCase(true, obj, {
        name = "",
        citations = {},
        islocal = true,
        include = true
    }, "local")
end

function TestCase:TestNewWithParamsLocal()
    local obj = case.new(
        "A v. B",
        { { type = "MLRA", year = "2010", vol  = "2", page = "293", } },
        true, true
    )

    helper.assertCase(true, obj)
end

function TestCase:TestNewWithParamsForeign()
    local obj = case.new(
        "C v. D",
        { "[1982] 3 All ER 38" },
        false, false
    )

    helper.assertCase(false, obj)
end

function TestCase:TestParseSingleCitation()
    local obj = case.new()
    obj:parse("A v. B [2010] 2 MLRA 293")

    helper.assertCase(true, obj)
end

function TestCase:TestParseMultipleCitation()
    local obj = case.new()
    obj:parse("A v. B [2010] 2 MLRA 293; [2010] 2 CLJ (Rep) 293")

    local expected = vim.deepcopy(helper.value.case.locale)
    table.insert(
        expected.citations,
        vim.deepcopy(helper.value.citation.locale.clj_rep)
    )

    helper.assertCase(true, obj, expected)
end

function TestCase:TestUpdate()
    local obj = case.new(
        "A v. B",
        { { type = "MLRA", year = "2010", vol  = "2", page = "293" } },
        true, true
    )
    obj:update(
        "C v. D",
        { { type = "MLRH", year = "2012", vol  = "3", page = "294", } },
        true, false
    )

    helper.assertCase(true, obj, {
        name = "C v. D",
        citations = { { type = "MLRH", year = "2012", vol  = "3", page = "294", } },
        islocal = true,
        include = false
    })
end

function TestCase:TestLinkLocalCase()
    local obj = case.new()
    obj:parse("A v. B [2010] 2 MLRA 293")
    local result = obj:link()
    lu.assertEquals(
        result,
        '<LINK HREF="case_notes/showcase.aspx?pageid=MLRA_2010_2_293;"><i>A v. B</i> [2010] 2 MLRA 293</LINK>'
    )
end

function TestCase:TestLinkForeignCase()
    local obj = case.new("C v. D", { "[1982] 3 All ER 38" }, false, false)
    local result = obj:link()
    lu.assertEquals(
        result,
        '<i>C v. D</i> [1982] 3 All ER 38'
    )
end

return TestCase
