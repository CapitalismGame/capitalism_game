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

function land.get_for_player(pname)
	assert(type(pname) == "string")
	assert(minetest.player_exists(pname))

	local comp = company.get_active(pname)
	if not comp then
		return nil
	end

	return land.get_for_company(comp)
end

function land.get_for_company(comp)

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

function land.can_set_price(area, pname)
	if not area or not area.land_type then
		return false, "Unable to sell unowned or unclassified (ie: c/i/r) area"
	end

	local comp = company.get_from_owner_str(area.owner)
	if not comp or not comp:is_government() then
		return false, "Only the government is currently able to sell land."
	end

	local comp_active = pname and company.get_active(pname)
	if pname and (not comp_active or comp_active.name ~= comp.name) then
		return false, "You do not own this area (do you need to change active company?)"
	end

	if pname and comp and
			not comp:check_perm(pname, "SELL_AREA", { area=area }) then
		return false, "You do not have permission to sell this area."
	end

	return true
end

function land.set_price(area, pname, price)
	if price <= 0 then
		return false, "Price must be greater than 0"
	end

	local suc, msg = land.can_set_price(area, pname)
	if not suc then
		return suc, msg
	end

	if pname then
		adt:post(pname, company.get_from_owner_str(area.owner),
				"Set price for area id=" .. area.id .. " to " .. price)
	end

	area.land_sale = price
	areas:save()
	return true
end
