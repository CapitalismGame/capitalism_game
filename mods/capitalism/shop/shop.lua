local Shop = {}
shop.Shop = Shop

function Shop:new(obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	obj.name = nil
	return obj
end

function Shop:to_table()
	return {
		name = self.name
	}
end

function Shop:from_table(tab)
	self.name = tab.name
	return true
end
