local luaunit = require("dstools.dependencies.luaunit")

TestUtil        = require("tests.unit.test_util")
TestCitation    = require("tests.unit.test_citation")
TestCase        = require("tests.unit.test_case")
TestLegislation = require("tests.unit.test_legislation")
TestCache       = require("tests.unit.test_cache")

luaunit.LuaUnit:run()
