minetest.register_privilege("land_admin")


ChatCmdBuilder.new("land", function(cmd)
	cmd:sub("debug", function(name)
		if not minetest.check_player_privs(name, { land_admin = true }) then
			return false, "Missing privilege: land_admin"
		end

		land.show_debug_to(name)
		return true, "Showed land debug form"
	end)
end, {
	description = "Land tools"
})

ChatCmdBuilder.new("zone", function(cmd)
	cmd:sub("new :id:int :type", function(name, id, type)
		if not areas.areas[id] then
			return false, "Unable to find area id=" .. id
		end

		if land.create_zone(id, type) then
			return true, "Marked area id=" .. id .. " as " .. type .. " zone"
		else
			return false, "Unexpected error"
		end
	end)
end, {
	description = "Land tools",
	privs = { zone_admin = true },
})
