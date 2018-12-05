_.extend(company, {
	_companies = {},
	_companies_by_name = {},
	_active_companies = {},
})

local adt = audit("company")
local player_exists = minetest and minetest.player_exists or
		function() return true end

function company.get_by_name(name)
	assert(type(name) == "string")

	return company._companies_by_name[name:lower()]
end

function company.check_name(name)
	return ("^(c:[a-z]+)$"):match(name)
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

	if not obj.name or
			#obj.name < 3 or
			obj.name:sub(1, 2) ~= "c:" or
			obj.name:sub(3, #obj.name):match("[^a-z_]") then
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
	assert(cname == nil or (type(cname) == "string" and cname:sub(1, 2) == "c:"))
	assert(type(permission) == "string")
	assert(company.permissions[permission])
	assert(meta == nil or type(meta) == "table")

	local comp = company.get_active(pname)
	if not comp then
		return false
	end

	if cname ~= nil and comp.name ~= cname then
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

function company.set_perms(comp, actor, target, permission, is_grant)
	if not comp:check_perm(actor, "MANAGE_MEMBERS",
			{ action = "add", name = "username" }) then
		return false, "Missing permission: MANAGE_MEMBERS"
	end

	if target == comp:get_ceo_name() then
		if is_grant then
			return false, "The CEO already has all permissions"
		else
			return false, "Permissions cannot be revoked from the CEO"
		end
	end

	permission = permission:upper()
	if permission ~= "ALL" and not company.permissions[permission] then
		return false, "Unknown permission " .. permission
	end

	local member = comp.members[target]
	if not member then
		return false, target .. " is not a member of " .. comp.title
	end

	if permission == "ALL" then
		for key in pairs(company.permissions) do
			member.perms[key] = is_grant
		end
	else
		member.perms[permission] = is_grant
	end

	company.dirty = true

	local perms = {}
	for key, value in pairs(member.perms) do
		if value then
			perms[#perms + 1] = key
		end
	end

	return true, "Permissions: " .. table.concat(perms, ", ")
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

company.registered_snippets = {}
function company.register_snippet(name, func)
	assert(type(name) == "string")
	assert(type(func) == "function")
	assert(not company.registered_snippets[name])

	company.registered_snippets[name] = func
end

-- Minetest won't be available in tests
if minetest then
	local storage = minetest.get_mod_storage()
	lib_utils.make_saveload(company, storage, "_companies", "add", company.Company)

	table.insert(company.__saves, function()
		storage:set_string("active_companies", minetest.serialize(company._active_companies))
	end)

	table.insert(company.__loads, function()
		company._active_companies =
			minetest.deserialize(storage:get_string("active_companies")) or {}
	end)

	company.load()
end
