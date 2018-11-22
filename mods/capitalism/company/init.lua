company = {}

print("[company] loading...")

dofile(minetest.get_modpath("company") .. "/permissions.lua")
dofile(minetest.get_modpath("company") .. "/company.lua")
dofile(minetest.get_modpath("company") .. "/api.lua")
dofile(minetest.get_modpath("company") .. "/chatcmds.lua")
dofile(minetest.get_modpath("company") .. "/gui.lua")

print("[company] loaded")
