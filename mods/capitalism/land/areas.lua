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
		area.id = id

		local is_company = area.owner:sub(1, 2) == "c:"
		if area.open then
			return true
		elseif is_company then
			if company.check_perm(name, area.owner, "INTERACT_AREA",
					{ area = area }) then
				return true
			end
		elseif area.owner == name then
			return true
		end
	end
	return false
end

function areas:isAreaOwner(id, name)
	local cur = self.areas[id]
	if cur and minetest.check_player_privs(name, self.adminPrivs) then
		return true
	end
	while cur do
		local is_company = cur.owner:sub(1, 2) == "c:"
		if is_company and
				company.check_perm(name, cur.owner, "OWNS_AREA", { area = cur }) then
			return true
		elseif cur.owner == name then
			return true
		elseif cur.parent then
			cur = self.areas[cur.parent]
		else
			return false
		end
	end
	return false
end

-- TODO: canInteractInArea
