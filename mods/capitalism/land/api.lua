--- Introduces land plots, and modifies areas to allow companies to own land.
--
-- This mod current uses areas as a backend, which means that a plot = an area.
--
-- @module land


--- Dictionary of valid types
land.valid_types = { commercial = true, residential = true, industrial = true }

local adt = audit("land")


--- Generates a tree representing land ownership hierarchy for a particular owner.
--
-- Each element returned will have a children property, which will be a table
-- of child elements.
--
-- @tparam [table] list A list of owned areas
-- @owner owner Player name or company name
-- @treturn (table,table) root, area by id
function land.get_area_tree(list, owner)
	assert(list == nil or type(list) == "table")
	assert(owner == nil or type(owner) == "string")

	list = list or areas.areas
	list = table.copy(list)

	local root = {}
	local item_by_id = {}
	local pending_by_id = {}

	if owner then
		for i=1, #list do
			if not list[i].marked and list[i].owner == owner then
				local ptr = i
				while ptr and not list[ptr].marked do
					list[ptr].marked = true
					ptr = list[ptr].parent
				end
			end
		end
	end

	for i=1, #list do
		local area    = list[i]
		area.id       = i
		area.children = {}

		if owner == nil or list[i].marked then
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
	end

	return root, item_by_id
end


--- Gets all plots owned by a particular owner
--
-- @owner owner Player name or company name
-- @treturn [table] List of plots
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


--- Gets the owning plot of a particular area
--
-- There is at most one owning area of a particular position; because
-- plots must not overlap, and any child of a plot most be fully contained.
--
-- This function essential returns the lowest plot in the tree at a particular
-- point
--
-- @pos pos
-- @treturn [table]
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


--- Gets a plot by its area ID (as in the mod area)
--
-- @int id
-- @treturn table plot
function land.get_by_area_id(id)
	assert(type(id) == "number")

	local area = areas.areas[id]
	return area and area.land_type and area
end


--- Transfers a plot between two owners, after checking relevant permissions.
--
-- @int id
-- @owner newowner
-- @player pname
-- @treturn true
-- @error Error message
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


--- Whether a user can put a plot up for sale, or change the price when already
-- for sale
--
-- @tparam table area
-- @player pname
-- @treturn true
-- @error Error message
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


--- Puts a plot up for sale, or changes the price when already for sale
--
-- @tparam table area
-- @player pname
-- @number price
-- @treturn true
-- @error Error message
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


--- Whether a user can buy a plot
--
-- @tparam table area
-- @player pname
-- @company comp
-- @treturn true
-- @error Error message
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


--- Buy a plot
--
-- @tparam table area
-- @player pname
-- @treturn true
-- @error Error message
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


--- Whether a user can teleport to a plot
--
-- @tparam table area
-- @player pname
-- @treturn true
-- @error Error message
function land.can_teleport_to(area, pname)
	if type(pname) == "userdata" then
		pname = pname:get_player_name()
	end

	assert(type(area) == "table")
	assert(type(pname) == "string")

	local comp  = company.get_active(pname)
	local owner = comp and comp.name or pname
	if area.owner ~= owner and not area.land_open then
		return false, "Not open and is owned by someone else (owner=" ..
				area.owner .. ")"
	end

	if not area.spawn_point then
		return false, "No spawn point"
	end

	return true
end


--- Teleport a user to a plot
--
-- @tparam table area
-- @param player Player userdata
-- @treturn true
-- @error Error message
function land.teleport_to(area, player)
	assert(type(area) == "table")
	assert(type(player) == "userdata")

	local suc, msg = land.can_teleport_to(area, player:get_player_name())
	if suc then
		player:set_pos(area.spawn_point)
	end
	if msg then
		minetest.log("warning", msg)
	end
	return suc, msg
end


--- Whether a user can set the spawn of a plot
--
-- @tparam table area
-- @player pname
-- @treturn true
-- @error Error message
function land.can_set_spawn(area, pname)
	if type(pname) == "userdata" then
		pname = pname:get_player_name()
	end

	assert(type(area) == "table")
	assert(type(pname) == "string")

	local comp  = company.get_active(pname)
	local owner = comp and comp.name or pname
	if area.owner ~= owner and not area.land_open then
		return false, "Unable to change spawn of land (" ..
				area.name .. " [" .. dump(area.id) .. "]), because it is not  " ..
				"owned by you (owner=" .. area.owner ..
				", you you need to switch companies?)"
	end

	if comp and not comp:check_perm(pname, "CHANGE_SPAWN", { area = area }) then
		return false, "Missing permission: CHANGE_SPAWN"
	end

	return true
end
