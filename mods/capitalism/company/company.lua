local Company = {}
company.Company = Company

function Company:new(obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	self.ceo     = nil
	self.members = {}
	return obj
end

function Company:to_table()
	assert(self.name:sub(1, 2) == "c:")
	return {
		title   = self.title,
		name    = self.name,
		ceo     = self.ceo,
		members = self.members,
	}
end

function Company:from_table(t)
	self.title   = t.title
	self.name    = t.name
	if self.name:sub(1, 2) ~= "c:" then
		self.name = "c:" .. self.name
	end
	self.ceo     = t.ceo or t.owner
	self.members = t.members or {}
	return self.name ~= nil and self.ceo ~= nil and type(self.members) == "table"
end

function Company:set_title_calc_name(title)
	assert(type(title) == "string")

	self.title = title
	self.name = "c:" .. title:lower():gsub("%W", "_")
end

function Company:get_ceo_name()
	return self.ceo
end

function Company:get_ownership(username)
	-- TODO: ownership
	if self.ceo == username then
		return 1
	else
		return 0
	end
end

function Company:can_become_active(username)
	return self:check_perm(username, "SWITCH_TO")
end

function Company:check_perm(username, permission, meta)
	assert(type(username) == "string")
	assert(type(permission) == "string")
	assert(company.permissions[permission])
	assert(meta == nil or type(meta) == "table")

	if self.ceo == username then
		return true
	end

	local member = self.members[username]
	return member and member.perms[permission] and true or false
end

function Company:add_member(username)
	assert(not self.members[username])

	local mem = {
		perms = {
			SWITCH_TO = true,
			INTERACT_AREA = true,
		},
	}

	self.members[username] = mem
	return mem
end

function Company:is_government()
	return self.name == "c:government"
end
