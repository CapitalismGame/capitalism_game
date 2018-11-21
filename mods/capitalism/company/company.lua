local Company = {}
company.Company = Company

function Company:new(obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	self.owner   = nil
	return obj
end

function Company:to_table()
	return {
		title   = self.title,
		name    = self.name,
		owner   = self.owner
	}
end

function Company:from_table(t)
	self.title   = t.title
	self.name    = t.name
	self.owner   = t.owner
	return self.name ~= nil and self.owner ~= nil
end

function Company:set_title_calc_name(title)
	assert(type(title) == "string")

	self.title = title
	self.name = title:lower():gsub("%W", "_")
end

function Company:get_ceo_name()
	return self.owner
end

function Company:get_ownership(username)
	-- TODO: ownership
	if self.owner == username then
		return 1
	else
		return 0
	end
end

function Company:can_become_active(username)
	return self:check_perm(username, "SWITCH_TO")
end

function Company:check_perm(username, permission)
	-- TODO: permissions
	return self:get_ownership(username) > 0
end

function Company:is_government()
	return self.name == "government"
end
