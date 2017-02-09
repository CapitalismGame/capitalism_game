local function copy_pos(pos)
	return { x = pos.x, y = pos.y, z = pos.z }
end

minetest.register_node("networks:wireless", {
	description = "Wireless Network Communicator",
	tiles = "default_stone.png",
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local placername = placer:get_player_name()
		local companyname = companies.get_current_company(placername)
		if not companyname then
			companies.show_select_company_message(placername)
			minetest.set_node(pos, { name = "air" })
			return true
		end

		local meta = minetest.get_meta(pos)
		meta:set_string("owner", companyname)
		meta:set_string("infotext", "Disconnected\nOwned by " .. companyname)

		networks.add_coms(pos, companyname, placername)
	end,
	groups = {choppy = 3, dig_immediate = 2, communicator = 1},
	on_sender_connected = function(pos, connector_pos)
		local def = networks.get_coms(pos)
		table.insert(def.senders, copy_pos(connector_pos))
	end,
	on_receiver_connected = function(pos, connector_pos)
		local def = networks.get_coms(pos)
		table.insert(def.receivers, copy_pos(connector_pos))
	end,
})
