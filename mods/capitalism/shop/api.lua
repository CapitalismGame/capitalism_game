--- Adds shops
--
-- @module shop

_.extend(shop, {
	_shops = {},
	_shops_by_area = {},
	_context = {}
})


--- Get a shop by its `land` area ID
--
-- @int aid
function shop.get_by_area(aid)
	assert(type(aid) == "number")
	return shop._shops_by_area[aid]
end


--- @pos pos
function shop.get_by_pos(pos)
	assert(type(pos) == "table")
	local area = land.get_by_pos(pos)
	return area and shop.get_by_area(area.id)
end


--- @tparam table s
function shop.add_shop(s)
	assert(not shop._shops_by_area[s.a_id])

	shop._shops[#shop._shops + 1] = s
	shop._shops_by_area[s.a_id] = s
	return true
end

--- Checks whether a user can use the admin interface for the shop
--
-- @player pname
-- @pos pos
function shop.can_admin(pname, pos)
	local area = land.get_by_pos(pos)
	local comp = company.get_by_name(area.owner)

	return comp and
		company.check_perm(pname, comp.name, "SHOP_ADMIN", { pos = pos })
end


--- Creates shops, checks permissions
--
-- @player pname
-- @pos pos
-- @treturn true
-- @error Error message
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


--- Unassigns item allocation of chest. Will return any items.
--
-- @shop s
-- @pos pos
-- @param inv Inventory userdata
function shop.unassign_chest(s, pos, inv)
	local chest = s:get_chest(pos)
	if chest.itemname then
		local stack = ItemStack(chest.itemname)
		stack:set_count(chest.count)

		if inv and inv:room_for_item("main", stack) then
			inv:add_item("main", stack)
		end

		local node_inv  = minetest.get_inventory({ type = "node", pos = pos })
		node_inv:set_list("main", {})

		local new = s:get_item_or_make(chest.itemname)
		new.stock = new.stock - chest.count
	end

	chest.itemname = nil
	chest.count    = 0
end


--- Can user buy from shop, checks permissions
--
-- @pos pos
-- @player pname
-- @string itemname
-- @int count
-- @int price
-- @treturn true
-- @error Error message
function shop.can_buy(pos, pname, itemname, count, price)
	assert(type(pos) == "table")
	assert(type(pname) == "string")
	assert(type(itemname) == "string" and minetest.registered_items[itemname])
	assert(type(count) == "number" and count >= 0)
	assert(type(price) == "number" and price >= 0)

	local comp = company.get_active(pname)
	if comp and not comp:check_perm(pname, "BUY_ITEMS",
			{ itemname = itemname, count = count, price = price }) then
		return false, "Missing permission: BUY_ITEMS"
	end

	local acc = banking.get_by_owner(comp and comp.name or pname)
	if not acc then
		return false, "You don't have a bank account"
	end

	if acc.balance < price then
		return false, "Insufficient funds"
	end

	return true
end


--- Buy from shop, checks permissions
--
-- @pos pos
-- @player pname
-- @tparam table item
-- @int count
--
-- @treturn true
-- @error Error message
function shop.buy(pos, pname, item, count)
	assert(type(pos) == "table")
	assert(type(pname) == "string")
	assert(type(item) == "table")
	assert(type(count) == "number" and count >= 0)

	if count > item.stock then
		return false, "Not enough stock"
	end

	local price = count * item.price

	local suc, msg = shop.can_buy(pos, pname, item.name, count, price)
	if not suc then
		return false, msg
	end

	local to_give = ItemStack({ name = item.name, count = count })
	local pinv = minetest.get_inventory({ type = "player", name = pname })
	if not pinv:room_for_item("main", to_give) then
		return false, "Not enough room in inv"
	end


	local area          = land.get_by_pos(pos)
	assert(area.owner:sub(1, 2) == "c:")
	local s             = shop.get_by_area(area.id)
	local comp          = company.get_active(pname)
	local account       = banking.get_by_owner(comp and comp.name or pname)
	local owner_account = banking.get_by_owner(area.owner)
	assert(account)
	assert(owner_account)

	-- Locate chest
	local chests = s:get_chests_for_item(item.name, count, function(chest)
		return minetest.get_node(chest.pos) ~= "ignore"
	end)

	if not chests then
		return false, "Map unloaded"
		-- chests = s:get_chests_for_item(item.name, count)
		--
		-- if not chests then
		-- 	return false, "Error: unexpected out of stock. This should never happen."
		-- end
	end

	local took = 0
	for i=1, #chests do
		local inv = minetest.get_inventory({ type = "node", pos = chests[i].pos })

		local stack = inv:remove_item("main", { name = item.name, count = count - took })
		if not stack:is_empty() then
			took = took + stack:get_count()
			s:chest_remove_item(chests[i].pos, stack)

			if took == count then
				break
			end
		end
	end

	assert(took == count)

	if not banking.transfer(pname, account.owner, owner_account.owner, price,
			"Purchase of item name=" .. item.name .. ", count=" .. count) then
		return false, "Card payment error"
	end

	pinv:add_item("main", to_give)

	shop.dirty = true

	return true
end


-- Minetest won't be available in tests
if minetest then
	local storage = minetest.get_mod_storage()
	lib_utils.make_saveload(shop, storage, "_shops", "add_shop", shop.Shop)
	shop.load()
end
