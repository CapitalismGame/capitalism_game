print("[networks] loading...")

dofile(minetest.get_modpath("networks") .. "/api.lua")
networks.init()
dofile(minetest.get_modpath("networks") .. "/communicators.lua")

print("[networks] load")
