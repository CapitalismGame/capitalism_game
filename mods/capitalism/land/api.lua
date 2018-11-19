land._zones = {}
land._zone_by_id = {}

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

function land.get_for_player(name)
	local comp = company.get_active(name)
	if not comp then
		return nil
	end

	return land.get_for_company(comp)
end

function land.get_for_company(comp)

end

function land.get_by_area_id(id)
	return land._zone_by_id[id]
end

function land.can_zone(id)
	local tree, area_by_id = land.get_area_tree()

	local function find_zone(list)
		for i=1, #list do
			if land._zone_by_id[list[i].id] then
				return false
			end

			if not find_zone(list[i].children) then
				return false
			end
		end

		return true
	end


	local area = area_by_id[id]
	assert(area)

	-- Check children
	if not find_zone(area.children) then
		return false
	end

	-- Check parents
	local pointer = area_by_id[area.parent]
	while pointer do
		if land._zone_by_id[pointer.id] then
			return false
		end

		pointer = area_by_id[pointer.parent]
	end

	return true
end


-- Creates a zone from an area
-- Any subareas will be sellable lots
-- Zones cannot overlap
function land.create_zone(id, type)
	if not land.can_zone(id) then
		return nil, "Can't zone id=" .. id
	end

	local zone = land.Zone:new()
	zone.id    = id
	zone.type  = type
	land.add_zone(zone)
	land.save()
	return zone
end

function land.remove_zone(id)
	for i=1, #land._zones do
		if land._zones[i].id == id then
			table.remove(land._zones, i)
			break
		end
	end

	land._zone_by_id[id] = nil
end

function land.add_zone(z)
	assert(z:is_valid())

	land._zones[#land._zones + 1] = z
	land._zone_by_id[z.id]        = z

	return z
end


areas:registerOnAdd(function(owner, name, pos1, pos2, parent)
	-- print(dump({ owner, name, pos1, pos2, parent }))
end)

areas:registerOnRemove(function(id)
	-- print(dump(id))
end)

areas:registerOnMove(function(id, area, pos1, pos2)
	-- print(dump({ id, area, pos1, pos2 }))
end)

local storage = minetest.get_mod_storage()
lib_utils.make_saveload(land, storage, "_zones", "add_zone", land.Zone)
land.load()
