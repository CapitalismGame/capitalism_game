local function copy_pos(pos)
	return { x = pos.x, y = pos.y, z = pos.z }
end

minetest.register_node("networks:wireless", {
	description = "Wireless Network Communicator",
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local placername = placer:get_player_name()
		local companyname = company.get_active_company_or_msg(placername)
		if not companyname then
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
	tiles = {
		"default_stone.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.1875, -0.5, -0.1875, 0.1875, -0.375, 0.1875}, -- Base
			{-0.125, -0.375, -0.125, 0.125, 0, 0.125}, -- Pole
			{-0.3125, 0, -0.3125, 0.3125, 0.125, 0.3125}, -- Dish
			{-0.125, 0.125, -0.125, 0.125, 0.3125, 0.125}, -- NodeBox4
			{-0.0625, 0.3125, -0.0625, 0.0625, 0.5, 0.0625}, -- NodeBox5
			{-0.375, 0, -0.25, -0.3125, 0.125, 0.25}, -- NodeBox7
			{-0.25, 0, -0.375, 0.25, 0.125, -0.3125}, -- NodeBox8
			{0.3125, 0, -0.25, 0.375, 0.125, 0.25}, -- NodeBox10
			{-0.25, 0, 0.3125, 0.25, 0.125, 0.375}, -- NodeBox11
			{-0.125, 0, 0.375, 0.125, 0.125, 0.4375}, -- NodeBox12
			{-0.4375, 0, -0.125, -0.375, 0.125, 0.125}, -- NodeBox13
			{0.375, 0, -0.125, 0.4375, 0.125, 0.125}, -- NodeBox14
			{-0.125, 0, -0.4375, 0.125, 0.125, -0.375}, -- NodeBox15
		}
	},
})
