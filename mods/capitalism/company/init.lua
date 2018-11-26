company = {}

print("[company] loading...")

dofile(minetest.get_modpath("company") .. "/permissions.lua")
dofile(minetest.get_modpath("company") .. "/company.lua")
dofile(minetest.get_modpath("company") .. "/api.lua")
dofile(minetest.get_modpath("company") .. "/chatcmds.lua")
dofile(minetest.get_modpath("company") .. "/gui.lua")

minetest.register_on_joinplayer(function(player)
	local pname = player:get_player_name()
	if #company.get_companies_for_player(pname) == 0 then
		minetest.chat_send_player(pname, minetest.colorize("#bef",
				"Register a company with   /company register <Name>\n" ..
				"Then have a look around. Try buying land or items"))
	end
end)

print("[company] loaded")
