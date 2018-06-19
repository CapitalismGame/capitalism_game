shop = {}

dofile(minetest.get_modpath("shop") .. "/shop.lua")
dofile(minetest.get_modpath("shop") .. "/api.lua")
dofile(minetest.get_modpath("shop") .. "/chatcmds.lua")

minetest.register_node("shop:counter", {
	description = "Counter",

	on_rightclick = function(pos, node, player)
		shop.show_shop_form(player, pos)
	end,

	after_place_node = function(pos, player)
		local playername = player:get_player_name()
		local comp = company.get_active_or_msg(playername)
		if comp then
			local meta = minetest.get_meta(pos)
			meta:set_string("infotest", "Unconfigured shop")
			meta:set_string("owner_company", comp.name)
		else
			minetest.remove_node(pos)
			return true
		end
	end,
})
