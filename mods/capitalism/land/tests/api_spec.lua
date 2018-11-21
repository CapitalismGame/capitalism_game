package.path = 'mods/?.lua;' ..
				package.path

_G.land = {}
_G.areas = { areas = {}, save = function() end }
_G.audit = function()
	return { post = function() end }
end

require("capitalism/land/api")

_G.company = {}
function company.get_from_owner_str(owner)
	local data
	if owner == "c:government" then
		data = { name = "government", title = "Government", owner = "testuser" }
	elseif owner == "c:test" then
		data = { name = "test", title = "Test", owner = "testuser" }
	else
		return nil
	end

	function data:check_perm(pname, perm, meta)
		return self.owner == pname
	end

	function data:is_government()
		return self.name == "government"
	end

	return data
end

function company.get_active(pname)
	if pname == "testuser" and company.is_active then
		return company.get_from_owner_str("c:government")
	end
end

_G.minetest = {
	player_exists = function(name)
		return name == "testuser"
	end,
	check_player_privs = function()
		return false
	end,
}


describe("land", function()
	it("get_by_area_id", function()
		assert.is_nil(land.get_by_area_id(1))

		areas.areas[1] = { owner = "c:test" }

		assert.is_nil(land.get_by_area_id(1))

		areas.areas[1].land_type = "commercial"

		assert.equals(land.get_by_area_id(1), areas.areas[1])
	end)

	it("transfer", function()
		local area = areas.areas[1]
		area.owner = "c:government"

		assert.equals(land.get_by_area_id(1), area)
		assert.equals(area.owner, "c:government")

		local suc, msg = land.transfer(2, "c:test", "testuser")
		assert.is_false(suc)
		assert.is_not_nil(msg:match("to find area"))
		assert.equals(area.owner, "c:government")

		suc, msg = land.transfer(1, "c:test", "testuser")
		assert.is_false(suc)
		assert.is_not_nil(msg:match("transfer root areas"))
		assert.equals(area.owner, "c:government")

		area.parent = 3

		suc, msg = land.transfer(1, "c:test", "testuser")
		assert.is_false(suc)
		assert.is_not_nil(msg:match("acting on behalf"))
		assert.equals(area.owner, "c:government")

		company.is_active = true

		suc, msg = land.transfer(1, "nonexist", "testuser")
		assert.is_false(suc)
		assert.is_not_nil(msg:match("did you forget"))
		assert.equals(area.owner, "c:government")

		suc, msg = land.transfer(1, "c:nonexist", "testuser")
		assert.is_false(suc)
		assert.is_not_nil(msg:match("doesn't exist"))
		assert.equals(area.owner, "c:government")

		suc = land.transfer(1, "c:test", "testuser")
		assert.is_true(suc)
		assert.equals(area.owner, "c:test")
	end)

	it("set_price", function()
		company.is_active = false
		local area = { owner = "c:test", id=1 }

		assert.is_nil(area.land_sale)
		local suc, msg = land.set_price(area, "foobar", 100)
		assert.is_false(suc)
		assert.is_not_nil(msg:match("unclassified"))

		area.land_type = "commercial"

		assert.is_nil(area.land_sale)
		suc, msg = land.set_price(area, "foobar", -1)
		assert.is_false(suc)
		assert.is_not_nil(msg:match("greater than"))

		assert.is_nil(area.land_sale)
		suc, msg = land.set_price(area, "foobar", 100)
		assert.is_false(suc)
		assert.is_not_nil(msg:match("government is currently able"))

		area.owner = "c:government"

		assert.is_nil(area.land_sale)
		suc, msg = land.set_price(area, "foobar", 100)
		assert.is_false(suc)
		assert.is_not_nil(msg:match("do not own"))

		assert.is_nil(area.land_sale)
		suc, msg = land.set_price(area, "testuser", 100)
		assert.is_false(suc)
		assert.is_not_nil(msg:match("do not own"))

		company.is_active = true

		assert.is_nil(area.land_sale)
		suc, msg = land.set_price(area, "foobar", 100)
		assert.is_false(suc)
		assert.is_not_nil(msg:match("do not own"))

		assert.is_nil(area.land_sale)
		suc = land.set_price(area, "testuser", 100)
		assert.is_true(suc)
		assert.equals(area.land_sale, 100)
	end)
end)
