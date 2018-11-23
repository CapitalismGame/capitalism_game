_.extend(shop, {
	_shops = {},
	_shops_by_area = {},
	_context = {}
})

function shop.get_by_area(aid)
	assert(type(aid) == "number")
	return shop._shops_by_area[aid]
end

function shop.get_by_pos(pos)
	assert(type(pos) == "table")
	local area = land.get_by_pos(pos)
	return area and shop.get_by_area(area.id)
end

function shop.add_shop(s)
	assert(not shop._shops_by_area[s.a_id])

	shop._shops[#shop._shops + 1] = s
	shop._shops_by_area[s.a_id] = s
	return true
end

function shop.init_inventory(name)
	return minetest.create_detached_inventory("shop_inv_" .. name, {
		allow_put = function(inv, listname, index, stack, player)
			return 0
		end,

		allow_take = function(inv, listname, index, stack, player)
			return 0
		end
	})
end

function shop.get_inventory_or_create(name)
	return minetest.get_inventory({
		type = "detached",
		name = "shop_inv_" .. name
	}) or shop.init_inventory(name)
end

function shop.can_admin(pname, pos)
	local area = land.get_by_pos(pos)
	local comp = company.get_by_name(area.owner)

	return comp and
		company.check_perm(pname, comp.name, "SHOP_ADMIN", { pos = pos })
end

function shop.create_shop(pname, pos)
	local area = land.get_by_pos(pos)
	local comp = company.get_by_name(area.owner)

	if not comp then
		return false, "You need to select a company to operate as"
	end

	if not company.check_perm(pname, comp.name, "SHOP_CREATE", { pos = pos }) then
		return false, "Missing permission: SHOP_CREATE"
	end

	local s = shop.Shop:new()
	s.a_id  = area.id
	s.name  = area.name
	shop.add_shop(s)

	shop.dirty = true
	return true
end

-- Minetest won't be available in tests
if minetest then
	local storage = minetest.get_mod_storage()
	lib_utils.make_saveload(shop, storage, "_shops", "add_shop", shop.Shop)
	shop.load()
end
