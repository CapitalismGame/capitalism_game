_.extend(company, {
	_companies = {},
	_companies_by_name = {},
	_active_companies = {}
})

local adt = audit("company")

function company.get_by_name(name)
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

function company.set_active(playername, comp)
	local cname = comp
	if type(cname) ~= "string" then
		cname = comp.name
	end

	adt:post(playername, cname, "Became active")

	comp = company.get_by_name(cname)
	if comp and comp:can_become_active(playername) then
		company._active_companies[playername] = cname:lower()
		return true
	else
		return false
	end
end

function company.get_active(playername)
	local name = company._active_companies[playername]
	return name and company.get_by_name(name) or nil
end

function company.check_perm(username, cname, permission, meta)
	local comp = company.get_active(username)
	if not comp then
		return false
	end

	if comp.name ~= cname then
		return false
	end

	return comp:check_perm(username, permission, meta)
end

function company.get_active_or_msg(playername)
	local comp = company.get_active(playername)
	if comp then
		return comp
	else
		minetest.chat_send_player(playername, minetest.colorize("#f33",
				"You need to select a company to operate as using /company use <name>"))
		return nil
	end
end

function company.get_companies_for_player(name)
	local comps = {}
	for _, comp in pairs(company._companies) do
		if comp:can_become_active(name) then
			comps[#comps + 1] = comp
		end
	end
	return comps
end

company.registered_on_creates = {}
function company.register_on_create(func)
	table.insert(company.registered_on_creates, func)
end

company.registered_panels = {}
function company.register_panel(def)
	table.insert(company.registered_panels, def)
end

-- Minetest won't be available in tests
if minetest then
	local storage = minetest.get_mod_storage()
	lib_utils.make_saveload(company, storage, "_companies", "add", company.Company)
	company.load()
end
