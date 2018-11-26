shop = {}

print("[shop] loading...")

dofile(minetest.get_modpath("shop") .. "/shop.lua")
dofile(minetest.get_modpath("shop") .. "/api.lua")
dofile(minetest.get_modpath("shop") .. "/gui.lua")
dofile(minetest.get_modpath("shop") .. "/chatcmds.lua")
dofile(minetest.get_modpath("shop") .. "/nodes.lua")


print("[shop] loaded")
