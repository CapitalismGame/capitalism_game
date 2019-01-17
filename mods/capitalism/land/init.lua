---
-- @module land

--- land table
land = {}

print("[land] loading...")

dofile(minetest.get_modpath("land") .. "/api.lua")
dofile(minetest.get_modpath("land") .. "/gui.lua")
dofile(minetest.get_modpath("land") .. "/chatcmds.lua")
dofile(minetest.get_modpath("land") .. "/nodes.lua")
dofile(minetest.get_modpath("land") .. "/areas.lua")

print("[land] loaded")
