land.valid_types = { commercial = true, residential = true, industrial = true }

local adt = audit("land")

function land.get_area_tree(list)
	list = list or areas.areas
	list = table.copy(list)

	local root = {}
	local item_by_id = {}
	local pending_by_id = {}

	for i=1, #list do
		local area    = list[i]
		area.id       = i
		area.children = {}

		if not area.parent then
			root[#root + 1] = area

			if pending_by_id[i] then
				area.children = pending_by_id
				pending_by_id[i] = nil
			end

		elseif item_by_id[area.parent] then
			local children = item_by_id[area.parent].children
			children[#children + 1] = area

		else
			pending_by_id[area.parent] = pending_by_id[area.parent] or {}
			local pending = pending_by_id[area.parent]
			pending[#pending + 1] = area
		end

		item_by_id[i]   = area
	end

	return root, item_by_id
end

function land.get_all(owner)
	local lands = {}
	for id, area in pairs(areas.areas) do
		if area.land_type and area.owner == owner then
			area.id = id
			lands[#lands + 1] = area
		end
	end

	return lands
end

function land.get_by_pos(pos)
	local areas = areas:getAreasAtPos(pos)

	local total = 0
	for id, area in pairs(areas) do
		total = total + 1

		if area.parent and areas[area.parent] then
			areas[area.parent] = nil
			total = total - 1
		end
	end

	assert(total == 0 or total == 1)

	local id, first = next(areas)

	first.id = id

	return first
end

function land.get_by_area_id(id)
	assert(type(id) == "number")

	local area = areas.areas[id]
	return area and area.land_type and area
end

function land.transfer(id, newowner, pname)
	assert(type(id) == "number")
	assert(type(newowner) == "string")
	assert(type(pname) == "string")

	local area = areas.areas[id]
	if not area then
		return false, "Unable to find area id=" .. id
	end

	if not area.parent then
		return false, "Unable to transfer root areas"
	end

	local land_admin = minetest.check_player_privs(pname, { land_admin = true })
	local comp       = company.get_by_name(area.owner)
	if not land_admin then
		if comp then
			local comp_active = company.get_active(pname)
			if not comp_active or comp_active.name ~= comp.name then
				return false, "You're not currently acting on behalf of " .. comp.title
			end

			if not comp:check_perm(pname, "TRANSFER_LAND") then
				return false, "Missing permission: TRANSFER_LAND"
			end
		elseif pname ~= area.owner then
			return false, "You don't have access to land owned by " .. area.owner
		end
	end

	if not minetest.player_exists(newowner) and
			not company.get_by_name(newowner)  then
		if newowner:sub(1, 2) == "c:" then
			return false, "New owner " .. newowner .. " doesn't exist"
		else
			return false, "New owner " .. newowner .. " doesn't exist (did you forget 'c:'?)"
		end
	end

	adt:post(pname, comp and comp.name, "Transferred area id=" .. id .. " to " .. newowner)

	area.owner = newowner
	areas:save()

	return true, "Transfered area id=" .. id .. " to " .. newowner
end

function land.can_set_price(area, pname)
	if not area or not area.land_type then
		return false, "Unable to sell unowned or unclassified (ie: c/i/r) area"
	end

	local comp = company.get_by_name(area.owner)
	if not comp or not comp:is_government() then
		return false, "Only the government is currently able to sell land."
	end

	if not area.parent then
		return false, "Root land is not sellable"
	end

	local comp_active = pname and company.get_active(pname)
	if pname and (not comp_active or comp_active.name ~= comp.name) then
		return false, "You do not own this area (do you need to change active company?)"
	end

	if pname and comp and
			not comp:check_perm(pname, "SELL_LAND", { area=area }) then
		return false, "You do not have permission to sell this area."
	end

	return true
end

function land.set_price(area, pname, price)
	assert(type(area) == "table")
	assert(pname == nil or type(pname) == "string")
	assert(type(price) == "number")

	if price <= 0 then
		return false, "Price must be greater than 0"
	end

	local suc, msg = land.can_set_price(area, pname)
	if not suc then
		return suc, msg
	end

	if pname then
		adt:post(pname, company.get_by_name(area.owner),
				"Set price for area id=" .. area.id .. " to " .. price)
	end

	area.land_sale = price
	areas:save()
	return true
end

function land.can_buy(area, pname, comp)
	assert(type(area) == "table")
	assert(type(pname) == "string")

	if comp and not comp:check_perm(pname, "BUY_LAND", { area = area }) then
		return false, "Missing permission: BUY_LAND"
	end

	if not area.parent then
		return false, "Unable to buy root areas"
	end

	if area.owner == comp.name then
		return false, "You already own this land!"
	end

	local acc = banking.get_by_owner(comp and comp.name or pname)
	if not acc then
		return false, "You don't have a bank account"
	end

	if acc.balance < area.land_sale then
		return false, "Insufficient funds"
	end

	return true
end

function land.buy(area, pname)
	assert(type(area) == "table")
	assert(type(pname) == "string")
	assert(minetest.player_exists(pname))

	local comp = company.get_active(pname)

	if not land.can_buy(area, pname, comp) then
		return false
	end

	local account = banking.get_by_owner(comp and comp.name or pname)
	local owner_account = banking.get_by_owner(area.owner)
	assert(account)
	assert(owner_account)

	if not banking.transfer(pname, account.owner, owner_account.owner, area.land_sale,
		"Purchase of land id=" .. area.id) then
		return false
	end

	adt:post(pname, comp,
			"Bought land id=" .. area.id .. " from " .. owner_account.owner)

	if minetest.get_node(area.land_postpos).name == "land:for_sale" then
		minetest.remove_node(area.land_postpos)
		minetest.remove_node(vector.add(area.land_postpos, {x=0,y=1,z=0}))
		area.land_postpos = nil
	end

	area.land_sale = nil
	area.owner     = comp and comp.name or pname
	areas:save()

	return true
end
