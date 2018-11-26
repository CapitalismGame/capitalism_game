minetest.register_node("land:for_sale", {
	description = "For Sale",
	drawtype="nodebox",
	paramtype = "light",
	walkable = false,
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png"
	},
	node_box = {
		type = "fixed",
		fixed = {
			{0.25,-0.5,0,0.3125,0.5,0.0625}
		}
	},
	groups = {immortal=1},
	after_place_node = function(pos, player)
		local pname = player and player:get_player_name()
		local area = land.get_by_pos(pos)

		if area.land_sale then
			minetest.remove_node(pos)
			if pname then
				minetest.chat_send_player(pname, "Land already for sale!")
			end
			return
		end

		local suc, msg = land.set_price(area, pname, 1000000)
		if suc then
			area.land_postpos = vector.new(pos)

			minetest.set_node(vector.add(pos, {x=0,y=1,z=0}),
				{ name = "land:for_sale_top" })
		else
			minetest.remove_node(pos)
		end

		if player then
			if suc then
				land.show_set_price_to(pname, area, pos)
			else
				minetest.chat_send_player(pname, msg)
			end
		end
	end,
	on_rightclick = function(pos, _, player)
		local area  = land.get_by_pos(pos)
		local pname = player:get_player_name()
		assert(area)

		if not area.land_sale then
			minetest.remove_node(pos)
			minetest.remove_node(vector.add(pos, {x=0,y=1,z=0}))
			return
		end

		area.land_postpos = vector.new(pos)

		if land.can_set_price(area, pname) then
			land.show_set_price_to(pname, area, pos)
		elseif area.land_sale then
			land.show_buy_to(pname, area)
		end
	end,
})

local for_sale_def = minetest.registered_nodes["land:for_sale"]

minetest.register_node("land:for_sale_top", {
	description = "You are not meant to have this! - flag top",
	drawtype    = "nodebox",
	paramtype   = "light",
	walkable    = false,
	tiles = {
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"default_wood.png",
		"land_for_sale_top_back.png",
		"land_for_sale_top.png"
	},
	node_box = {
		type = "fixed",
		fixed = {
			{0.250000,-0.500000,0.000000,0.312500,0.500000,0.062500},
			{-0.5,0,0.000000,0.250000,0.500000,0.062500}
		}
	},
	groups = {immortal=1,not_in_creative_inventory=1},

	on_rightclick = function(pos, ...)
		pos = vector.subtract(pos, {x=0,y=1,z=0})
		local below = minetest.get_node(pos)
		assert(below.name == "land:for_sale")

		return for_sale_def.on_rightclick(pos, ...)
	end,
})
