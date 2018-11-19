ChatCmdBuilder.new("land", function(cmd)
	cmd:sub("debug", function(name)
		land.show_debug_to(name)
	end)
end, {
	description = "Land tools"
})


minetest.register_privilege("zone_admin")

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
