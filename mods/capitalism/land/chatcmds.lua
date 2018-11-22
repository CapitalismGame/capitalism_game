minetest.register_privilege("land_admin", {
	give_to_singleplayer = false,
})


ChatCmdBuilder.new("land", function(cmd)
	cmd:sub("admin", function(name)
		if not minetest.check_player_privs(name, { land_admin = true }) then
			return false, "Missing privilege: land_admin"
		end

		land.show_debug_to(name)
		return true, "Showed land debug form"
	end)


	cmd:sub("list", function(name)
		local comp  = company.get_active(name)
		local owner = comp and comp.name or name
		local areas = land.get_all(owner)

		return true, "Areas owned by " .. owner .. "\n" ..
			table.concat(_.map(areas, function(area)
				return " - " .. area.name .. " [id=" .. area.id .. "]"
			end), "\n")
	end)

	cmd:sub("owner :id:int :newowner:owner", function(name, id, newowner)
		return land.transfer(id, newowner, name)
	end)

	cmd:sub("owner :id:int", function(name, id)
		local area = areas.areas[id]
		if not area then
			return false, "Unable to find area id=" .. id
		end

		return true, area.owner
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
