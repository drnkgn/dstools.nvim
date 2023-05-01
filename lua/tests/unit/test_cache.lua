local lu = require("dstools.dependencies.luaunit")
local helper = require("tests.helper")

local cache = require "dstools.cache"

local TestCache = {}

function TestCache:TestLoadCache()
    local result = cache.load_cache("lua/tests/mock/file_load.json")

    lu.assertNotNil(result)
    lu.assertIsTable(result)

    result = cache.load_cache("lua/tests/mock/file.json") -- file.json does not exists
    lu.assertIsNil(result)
end

function TestCache:TestLoadCacheLegislation()
    local tbl = cache.load_cache("lua/tests/mock/file_load.json")

    helper.assertLegislation(tbl.legislations[1])
end

function TestCache:TestLoadCacheCase()
    local tbl = cache.load_cache("lua/tests/mock/file_load.json")

    helper.assertCase(true, tbl.cases[1])  -- local case
    helper.assertCase(false, tbl.cases[2]) -- foreign case
end

function TestCache:TestStoreCache()
    local tbl = cache.load_cache("lua/tests/mock/file_load.json")
    cache.set_cache(tbl)
    cache.store_cache("lua/tests/mock/file_store.json")
end

return TestCache
