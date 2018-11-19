land._zones = {}
land._zone_by_id = {}

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


-- Creates a zone from an area
-- Any subareas will be sellable lots
-- Zones cannot overlap
function land.create_zone(id, type)
	local zone = land.Zone:new()
	zone.id    = id
	zone.type  = type
	land.add_zone(zone)
	return zone
end

function land.add_zone(z)
	assert(z:is_valid())

	land._zones[#land._zones + 1] = z
	land._zone_by_id[z.id]        = z
end


areas:registerOnAdd(function(owner, name, pos1, pos2, parent)
	print(dump({ owner, name, pos1, pos2, parent }))
end)

areas:registerOnRemove(function(id)
	print(dump(id))
end)

areas:registerOnMove(function(id, area, pos1, pos2)
	print(dump({ id, area, pos1, pos2 }))
end)

local storage = minetest.get_mod_storage()
lib_utils.make_saveload(land, storage, "_zones", "add_zone", land.Zone)
land.load()
