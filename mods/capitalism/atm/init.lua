minetest.register_node("atm:atm", {
	description = "ATM",
	tiles = "default_cobble.png",
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

		local com_pos = networks.find_near_and_connect(pos, companyname, nil, nil)
		if com_pos then
			minetest.chat_send_player(placername,
					"Automatically connected to communicator at " ..
					minetest.pos_to_string(com_pos))
			meta:set_string("infotext", "Connected\nOwned by " .. companyname)
		else
			meta:set_string("infotext", "Disconnected\nOwned by " .. companyname)
		end
	end,
	groups = {choppy = 3, dig_immediate = 2},
	on_sender_connected = function(pos, connector_pos)
		local def = networks.get_coms(pos)
		table.insert(def.senders, copy_pos(connector_pos))
	end,
	on_receiver_connected = function(pos, connector_pos)
		local def = networks.get_coms(pos)
		table.insert(def.receivers, copy_pos(connector_pos))
	end,
})
