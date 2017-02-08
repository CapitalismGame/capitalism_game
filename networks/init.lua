networks = {}

minetest.register_node("networks:wireless", {
	description = "Wireless Network Communicator",
	tiles = "default_stone.png",
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local companyname = companies.get_current_company(placer:get_player_name())
		if not companyname then
			companies.show_select_company_message(placer:get_player_name())
			minetest.set_node(pos, { name = "air" })
			return true
		end

		local meta = minetest.get_meta(pos)
		meta:set_string("owner", companyname)
	end,
	groups = {choppy = 3, dig_immediate = 2},
})
