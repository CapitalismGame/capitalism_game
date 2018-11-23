shop = {}

print("[shop] loading...")

dofile(minetest.get_modpath("shop") .. "/shop.lua")
dofile(minetest.get_modpath("shop") .. "/api.lua")
dofile(minetest.get_modpath("shop") .. "/gui.lua")
dofile(minetest.get_modpath("shop") .. "/chatcmds.lua")

minetest.register_node("shop:counter", {
	description = "Counter",

	on_rightclick = function(pos, node, player)
		shop.show_shop_form(player:get_player_name(), pos)
	end,

	after_place_node = function(pos, player)
		local pname    = player:get_player_name()
		local suc, msg = shop.create_shop(pname, pos)
		if suc then
			shop.show_shop_form(pname, pos)
		else
			minetest.chat_send_player(pname, msg)
			minetest.remove_node(pos)
			return true
		end
	end,
})

print("[shop] loaded")
