_.extend(company, {
	_companies = {},
	_companies_by_name = {},
	_active_companies = {}
})

local adt = audit("company")
local player_exists = minetest and minetest.player_exists or
		function() return true end

function company.get_by_name(name)
	assert(type(name) == "string")

	return company._companies_by_name[name:lower()]
end

function company.get_from_owner_str(str)
	assert(type(str) == "string")

	if str:sub(1, 2) ~= "c:" then
		return nil
	end

	local cname = str:sub(3, #str)
	return company.get_by_name(cname)
end

function company.create(obj)
	assert(type(obj) == "table")
	assert(obj.get_ownership)

	if not company.add(obj) then
		return false
	end

	company.dirty = true

	for _, func in pairs(company.registered_on_creates) do
		func(obj)
	end

	return true
end

function company.add(obj)
	assert(type(obj) == "table")
	assert(obj.get_ownership)

	if not obj.name or obj.name:match("[^a-z_]") then
		print("/!\\ Company name is invalid: " .. obj.name)
		return false
	elseif company._companies_by_name[obj.name] then
		print("/!\\ Company name is already registered")
		return false
	end

	company._companies_by_name[obj.name] = obj
	company._companies[#company._companies + 1] = obj

	return true
end

function company.set_active(pname, comp)
	assert(type(pname) == "string")
	assert(player_exists(pname))

	local cname = comp
	if type(cname) ~= "string" then
		cname = comp.name
	end

	adt:post(pname, cname, "Became active")

	comp = company.get_by_name(cname)
	if comp and comp:can_become_active(pname) then
		company._active_companies[pname] = cname:lower()
		return true
	else
		return false
	end
end

function company.get_active(pname)
	assert(type(pname) == "string")
	assert(player_exists(pname))

	local name = company._active_companies[pname]
	return name and company.get_by_name(name) or nil
end

function company.check_perm(pname, cname, permission, meta)
	assert(type(pname) == "string")
	assert(player_exists(pname))
	assert(type(cname) == "string")
	assert(type(permission) == "string")

	local comp = company.get_active(pname)
	if not comp then
		return false
	end

	if comp.name ~= cname then
		return false
	end

	return comp:check_perm(pname, permission, meta)
end

function company.get_active_or_msg(pname)
	assert(type(pname) == "string")
	assert(player_exists(pname))

	local comp = company.get_active(pname)
	if comp then
		return comp
	else
		minetest.chat_send_player(pname, minetest.colorize("#f33",
				"You need to select a company to operate as using /company use <name>"))
		return nil
	end
end

function company.get_companies_for_player(pname)
	assert(type(pname) == "string")
	assert(player_exists(pname))

	local comps = {}
	for _, comp in pairs(company._companies) do
		if comp:can_become_active(pname) then
			comps[#comps + 1] = comp
		end
	end
	return comps
end

company.registered_on_creates = {}
function company.register_on_create(func)
	assert(type(func) == "function")

	table.insert(company.registered_on_creates, func)
end

company.registered_panels = {}
function company.register_panel(def)
	assert(type(def) == "table")

	table.insert(company.registered_panels, def)
end

-- Minetest won't be available in tests
if minetest then
	local storage = minetest.get_mod_storage()
	lib_utils.make_saveload(company, storage, "_companies", "add", company.Company)
	company.load()
end
