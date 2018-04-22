local Company = {}
company.Company = Company

function Company:new(obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	self.balance = 0
	self.owner   = nil
	return obj
end

function Company:to_table()
	return {
		name    = self.name,
		balance = self.balance,
		owner   = self.owner
	}
end

function Company:from_table(t)
	self.name    = t.name
	self.balance = t.balance
	self.owner   = t.owner
	return self.name ~= nil and self.balance ~= nil and self.owner ~= nil
end

function Company:get_balance()
	-- TODO: banks
	return self.balance
end

function Company:get_primary_owner()
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

function Company:check_user_permission(username, permisson)
	-- TODO: permissions
	return self:get_ownership(username) > 0
end
