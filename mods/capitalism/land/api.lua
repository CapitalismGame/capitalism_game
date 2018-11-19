land.valid_types = { commercial = true, residential = true, industrial = true }

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
	local area = areas.areas[id]
	return area.land_type and area
end


areas:registerOnAdd(function(id, area)
	local parent = areas.areas[area.parent] or {}
	area.land_type = parent.land_type
	areas:save()
end)

function areas:canInteract(pos, name)
	if minetest.check_player_privs(name, self.adminPrivs) then
		return true
	end

	local areas = self:getAreasAtPos(pos)

	-- TODO: protect children from parents
	--
	-- local area_by_id = {}
	-- for _, area in pairs(areas) do
	-- 	area_by_id[area.id] = area
	-- end

	for id, area in pairs(areas) do
		local is_company = area.owner:sub(1, 2) == "c:"
		if area.open then
			return true
		elseif is_company then
			local cname = area.owner:sub(3, #area.owner)
			if company.check_perm(name, cname, "INTERACT_AREA", id) then
				return true
			end
		elseif area.owner == name then
			return true
		end
	end
	return false
end
