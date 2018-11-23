local Shop = {}
shop.Shop = Shop

function Shop:new(obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	obj.name = nil
	obj.a_id = nil
	return obj
end

function Shop:to_table()
	return {
		name = self.name,
		a_id = self.a_id
	}
end

function Shop:from_table(tab)
	self.name = tab.name
	self.a_id = tab.a_id
	return self.a_id ~= nil
end

function Shop:get_items()
	-- TODO: Implement this
	return {
		{ description = "Chips", stock = 1000, price = 10, sold = 100 },
		{ description = "Phones", stock = 10, price = 10000, sold = 2 },
		{ description = "Silicon", stock = 100, price = 2, sold = 0 },
	}
end
