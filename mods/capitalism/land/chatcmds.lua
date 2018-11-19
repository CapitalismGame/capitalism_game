minetest.register_privilege("land_admin")


ChatCmdBuilder.new("land", function(cmd)
	cmd:sub("debug", function(name)
		if not minetest.check_player_privs(name, { land_admin = true }) then
			return false, "Missing privilege: land_admin"
		end

		land.show_debug_to(name)
		return true, "Showed land debug form"
	end)

	cmd:sub("zone :id:int :type", function(name, id, type)
		if not minetest.check_player_privs(name, { land_admin = true }) then
			return false, "Missing privilege: land_admin"
		end

		if not areas.areas[id] then
			return false, "Unable to find area id=" .. id
		end

		if land.create_zone(id, type) then
			return true, "Marked area id=" .. id .. " as " .. type .. " zone"
		else
			return false, "Unexpected error"
		end
	end)

	cmd:sub("unzone :id:int", function(name, id)
		if not minetest.check_player_privs(name, { land_admin = true }) then
			return false, "Missing privilege: land_admin"
		end

		if not areas.areas[id] then
			return false, "Unable to find area id=" .. id
		end

		if not land._zone_by_id[id] then
			return false, "Area id=" .. id .. " is not a zone"
		end

		if land.remove_zone(id) then
			return true, "Marked area id=" .. id .. " as " .. type .. " zone"
		else
			return false, "Unexpected error"
		end
	end)
end, {
	description = "Land tools",
})
