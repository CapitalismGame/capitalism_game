---
-- @module banking

--- banking table
banking = {}

print("[banking] loading...")

dofile(minetest.get_modpath("banking") .. "/account.lua")
dofile(minetest.get_modpath("banking") .. "/api.lua")
dofile(minetest.get_modpath("banking") .. "/gui.lua")
dofile(minetest.get_modpath("banking") .. "/chatcmds.lua")


local storage = minetest.get_mod_storage()
lib_utils.make_saveload(banking, storage, "_accounts", "add_account", banking.Account)
banking.load()

for _, comp in pairs(company._companies) do
	if not banking.get_by_owner(comp.name) then
		assert(comp.name:sub(1, 2) == "c:")
		local acc = banking.Account:new()
		acc.owner = comp.name
		banking.add_account(acc)
	end
end

print("[banking] loaded")
