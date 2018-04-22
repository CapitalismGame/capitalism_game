_.extend(company, {
	_companies = {},
	_companies_by_name = {},
	_active_companies = {}
})

function company.get_by_name(name)
	return company._companies_by_name[name:lower()]
end

function company.register_company(name, obj)
	name = name:lower()
	if company._companies_by_name[name] then
		return false
	end

	obj.name = name
	company._companies_by_name[name] = obj
	company._companies[#company._companies + 1] = obj

	return true
end

function company.set_active_company(playername, comp)
	if type(comp) ~= "string" then
		comp = comp.name
	end

	if company.get_by_name(comp) then
		company._active_companies[playername] = comp:lower()
		return true
	else
		return false
	end
end

function company.get_active_company(playername)
	local name = company._active_companies[playername]
	return name and company.get_by_name(name) or nil
end

function company.get_active_company_or_msg(playername)
	local comp = company.get_active_company(playername)
	if comp then
		return comp
	else
		minetest.chat_send_player(playername, minetest.colorize("#f33",
				"You need to select a company to operate as using /company use <name>"))
		return nil
	end
end

local storage = minetest.get_mod_storage()
lib_utils.make_saveload(company, storage, "_companies", "register_company", company.Company)

company.load()
