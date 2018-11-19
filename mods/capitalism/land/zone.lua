local Zone = {}
land.Zone = Zone

function Zone:new(obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	return obj
end

function Zone:to_table()
	return {
		type = self.type,
		id   = self.id
	}
end

function Zone:from_table(tab)
	self.type = tab.type
	self.id   = tab.id
	return true
end

function Zone:is_valid()
	return self.id ~= nil and self.type ~= nil
end
