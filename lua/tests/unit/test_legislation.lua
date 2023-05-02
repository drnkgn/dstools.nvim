local lu = require("dstools.dependencies.luaunit")
local helper = require("tests.helper")

local legislation = require "dstools.legislation"

local TestLegislation = {}

function TestLegislation:TestNewWithParamsWithoutSectionAndRule()
    local obj = legislation.new(
        "Rules of Court 2012",
        "MY_PUAS_2012_205",
        "", "", true
    )

    local expected = vim.deepcopy(helper.value.legislation)
    expected.section, expected.rule = nil, nil

    helper.assertLegislation(obj, expected)
end

function TestLegislation:TestNewWithParamsWithSectionAndRule()
    local obj = legislation.new(
        "Rules of Court 2012",
        "MY_PUAS_2012_205",
        "53", "2", true
    )

    helper.assertLegislation(obj)
end

function TestLegislation:TestLinkWithSectionAndRule()
    local obj = legislation.new(
        "Rules of Court 2012",
        "MY_PUAS_2012_205",
        "53", "2", true
    )

    lu.assertEquals(
        obj:link("ROC"),
        '<LINK HREF="legislationSectiondisplayed.aspx?MY_PUAS_2012_205;53;SN2.;;">ROC</LINK>'
    )
end

function TestLegislation:TestLinkWithSectionOnly()
    local obj = legislation.new(
        "Rules of Court 2012",
        "MY_PUAS_2012_205",
        "53", "2", true
    )

    --- Test with section only
    obj:update(nil, nil, nil, "", nil)
    lu.assertEquals(
        obj:link("ROC"),
        '<LINK HREF="legislationSectiondisplayed.aspx?MY_PUAS_2012_205;53.;;">ROC</LINK>'
    )
end

function TestLegislation:TestLinkWithoutSectionOrRule()
    local obj = legislation.new(
        "Rules of Court 2012",
        "MY_PUAS_2012_205",
        "53", "2", true
    )

    --- Test without section or rule
    obj:update(nil, nil, "", "", nil)
    lu.assertEquals(
        obj:link("ROC"),
        '<LINK HREF="legislationMainDisplayed.aspx?MY_PUAS_2012_205;;">ROC</LINK>'
    )
end

return TestLegislation
