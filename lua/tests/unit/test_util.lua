local lu = require("dstools.dependencies.luaunit")

local util = require "dstools.util"

local TestUtil = {}

function TestUtil:TestIff()
    --- Expected: false
    local a = true
    local result = util.iff(a, false, "test")
    lu.assertFalse(result)
end

function TestUtil:TestIfnil()
    --- Expected: false
    local a = false
    local result = util.ifnil(a, "test")
    lu.assertFalse(result)
end

function TestUtil:TestFileExists()
    --- Expected: false
    lu.assertFalse(util.file_exists("lua/tests/mock/file_not_found.txt"), false) -- file_not_found.txt does not exists
    --- Expected: true
    lu.assertTrue(util.file_exists("lua/tests/mock/file.txt"), true)
end

function TestUtil:TestGenerateDefaultFilename()
    --- Expected: TEMP_run.lua
    lu.assertEquals(util.generate_default_filename(), "TEMP_run.lua")
end

return TestUtil
