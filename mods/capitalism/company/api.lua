_.extend(company, {
	_companies = {},
	_companies_by_name = {},
	_active_companies = {}
})

function company.get_by_name(name)
	return company._companies_by_name[name:lower()]
end

function company.register(name, obj)
	name = name:lower()
	if company._companies_by_name[name] then
		return false
	end

	obj.name = name
	company._companies_by_name[name] = obj
	company._companies[#company._companies + 1] = obj

	return true
end

function company.set_active(playername, comp)
	local cname = comp
	if type(cname) ~= "string" then
		cname = comp.name
	end

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

-- Minetest won't be available in tests
if minetest then
	local storage = minetest.get_mod_storage()
	lib_utils.make_saveload(company, storage, "_companies", "register", company.Company)
	company.load()
end
