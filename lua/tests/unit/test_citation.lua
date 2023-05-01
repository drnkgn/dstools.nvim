local lu = require("dstools.dependencies.luaunit")
local helper = require("tests.helper")

local citation = require "dstools.citation"

local TestCitation = {}

function TestCitation:TestNewWithParams()
    local obj = citation.new("MLRA", "2010", "2", "293")

    helper.assertCitation(obj)
end

function TestCitation:TestParseMLRA()
    local obj = citation.new()
    obj:parse("[2010] 2 MLRA 293")

    helper.assertCitation(obj)
end

function TestCitation:TestParseCLJRep()
    local obj = citation.new()
    obj:parse("[2010] 2 CLJ (Rep) 293")

    helper.assertCitation(obj, {
        type = "CLJ (Rep)",
        year = "2010",
        vol  = "2",
        page = "293"
    })
end

function TestCitation:TestFormatAsCitation()
    local obj = citation.new("MLRA", "2010", "2", "293")

    lu.assertEquals(
        obj:format("citation"),
        "[2010] 2 MLRA 293"
    )
end

function TestCitation:TestFormatAsPageid()
    local obj = citation.new("MLRA", "2010", "2", "293")

    lu.assertEquals(
        obj:format("pageid"),
        "MLRA_2010_2_293"
    )
end

return TestCitation
