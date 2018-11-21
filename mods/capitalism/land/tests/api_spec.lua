package.path = 'mods/?.lua;' ..
				package.path

-- _G.company = {}
_G.land = {}
_G.areas = { areas = {} }
_G.audit = function()
	return { post = function() end }
end

-- require("libs/lib_underscore/init")
-- require("capitalism/company/api")
-- require("capitalism/company/company")
require("capitalism/land/api")

describe("land", function()
	it("get_by_area_id", function()
		assert.is_nil(land.get_by_area_id(1))

		areas.areas[1] = { owner = "c:test" }

		assert.is_nil(land.get_by_area_id(1))

		areas.areas[1].land_type = "commercial"

		assert.equals(land.get_by_area_id(1), areas.areas[1])
	end)
end)
