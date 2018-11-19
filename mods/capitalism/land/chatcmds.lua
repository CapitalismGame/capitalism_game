minetest.register_privilege("land_admin", {
	give_to_singleplayer = false,
})


ChatCmdBuilder.new("land", function(cmd)
	cmd:sub("debug", function(name)
		if not minetest.check_player_privs(name, { land_admin = true }) then
			return false, "Missing privilege: land_admin"
		end

		land.show_debug_to(name)
		return true, "Showed land debug form"
	end)

	cmd:sub("set_type :id:int :type", function(name, id, type)
		if not minetest.check_player_privs(name, { land_admin = true }) then
			return false, "Missing privilege: land_admin"
		end

		if not land.valid_types[type] then
			return false, "Invalid type " .. type
		end

		local area = areas.areas[id]
		if not area then
			return false, "Unable to find area id=" .. id
		end

		area.land_type = type
		areas:save()

		return true, "Set type for area id=" .. id .. " to " .. type
	end)

	cmd:sub("remove_type :id:int", function(name, id)
		if not minetest.check_player_privs(name, { land_admin = true }) then
			return false, "Missing privilege: land_admin"
		end

		local area = areas.areas[id]
		if not area then
			return false, "Unable to find area id=" .. id
		end

		area.land_type = nil
		areas:save()

		return true, "Removed type"
	end)
end, {
	description = "Land tools",
})
