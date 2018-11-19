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

function land.regen_can_zone_cache()
	local tree, area_by_id = land.get_area_tree()
	local cache = {}
	land._can_zone_cache = cache

	local function mark_all(list)
		for i=1, #list do
			cache[list[i].id] = false
			mark_all(list[i].children)
		end

		return true
	end

	for _, zone in pairs(land._zones) do
		local area = area_by_id[zone.id]
		assert(area)

		cache[zone.id] = false
		mark_all(area.children)

		local pointer = area_by_id[area.parent]
		while pointer do
			cache[pointer.id] = false
			pointer = area_by_id[pointer.parent]
		end
	end

	assert(land._can_zone_cache)

	return cache
end

function land.invalidate_can_zone_cache()
	land._can_zone_cache = nil
end

function land.can_zone(id)
	if not land._can_zone_cache then
		land.regen_can_zone_cache()
	end

	assert(id ~= nil)

	return land._can_zone_cache[id] ~= false
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
	land.invalidate_can_zone_cache()
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
	land.save()
	land.invalidate_can_zone_cache()
end

function land.add_zone(z)
	assert(z:is_valid())

	land._zones[#land._zones + 1] = z
	land._zone_by_id[z.id]        = z

	return z
end


areas:registerOnAdd(function(owner, name, pos1, pos2, parent)
	land.invalidate_can_zone_cache()
end)

areas:registerOnRemove(function(id)
	land.invalidate_can_zone_cache()
end)

areas:registerOnMove(function(id, area, pos1, pos2)
	-- print(dump({ id, area, pos1, pos2 }))
end)

local storage = minetest.get_mod_storage()
lib_utils.make_saveload(land, storage, "_zones", "add_zone", land.Zone)
land.load()
