---
-- @module company

--- Company
--
-- Class which represents a company or government entity.
-- @type Company
local Company = {}

company.Company = Company


--- Constructor
--
-- @param obj A table to construct an object on top of
-- @treturn company.Company
function Company:new(obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	self.ceo     = nil
	self.members = {}
	return obj
end


--- Export to Lua table
--
-- @treturn table
function Company:to_table()
	assert(self.name:sub(1, 2) == "c:")
	return {
		title   = self.title,
		name    = self.name,
		ceo     = self.ceo,
		members = self.members,
	}
end


--- Import from Lua table
--
-- @tparam table t
-- @treturn bool true on success, false on failure
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


--- Calculate an appropriate name from a given title
--
-- @string title
function Company:set_title_calc_name(title)
	assert(type(title) == "string")

	self.title = title
	self.name = "c:" .. title:lower():gsub("%W", "_")
end


--- Get the name of the current CEO or president
--
-- @treturn string
function Company:get_ceo_name()
	return self.ceo
end


--- How must does a particular username own of this company?
--
-- @string username
-- @treturn number Proportion of ownership, as a number out of 1.
function Company:get_ownership(username)
	-- TODO: ownership
	if self.ceo == username then
		return 1
	else
		return 0
	end
end


--- Whether a particular player can act as this company
--
-- @string username
-- @treturn bool
function Company:can_become_active(username)
	return self:check_perm(username, "SWITCH_TO")
end


--- Check whether a player has a certain permission
--
-- @see company.permissions
-- @string username the username
-- @string permission permission name, string
-- @tparam ?table meta Metadata about this request
-- @treturn bool
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


--- Adds a member to the company
--
-- Members are players other than the CEO that can have permissions
-- granted to them by the company
--
-- @string username
-- @treturn Member table
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


--- Check whether this company is a governmental entity.
--
-- Note: does NOT check whether the company is public or government-owned.
-- This condition imposes certain requirements on the government entity,
-- such as elections and voting, which do not make sense with government-owned
-- companies.
--
-- @treturn bool
function Company:is_government()
	return self.name == "c:government"
end
