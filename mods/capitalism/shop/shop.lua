local Shop = {}
shop.Shop = Shop

function Shop:new(obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self

	obj.name   = nil
	obj.a_id   = nil
	obj.chests = {}
	obj.items  = {}

	return obj
end

function Shop:to_table()
	return {
		name   = self.name,
		a_id   = self.a_id,
		chests = self.chests,
		items  = self.items,
	}
end

function Shop:from_table(tab)
	self.name   = tab.name
	self.a_id   = tab.a_id
	self.chests = tab.chests or {}
	self.items  = tab.items  or {}

	return self.a_id ~= nil
end

function Shop:get_items()
	return self.items
end

function Shop:get_item(name)
	return self.items[name]
end

function Shop:get_item_or_make(name)
	local item = self.items[name] or {
		name  = name,
		stock = 0,
		price = -1,
		sold  = 0,
	}

	self.items[name] = item
	return item
end

function Shop:add_chest(pos)
	local posstr = minetest.pos_to_string(vector.floor(pos))
	assert(not self.chests[posstr])
	self.chests[posstr] = {
		pos      = vector.new(pos),
		itemname = nil,
		count    = 0,
	}
end

function Shop:get_chest(pos)
	local posstr = minetest.pos_to_string(vector.floor(pos))
	return self.chests[posstr]
end

function Shop:get_chests_for_item(name, count, filter)
	local ret = {}
	for _, chest in pairs(self.chests) do
		if chest.itemname == name and chest.count > 0 and (not filter or filter(chest)) then
			count = count - chest.count
			ret[#ret + 1] = chest
			if count <= 0 then
				return ret
			end
		end
	end

	return nil
end

function Shop:chest_poll(pos, inv)
	local chest = self:get_chest(pos)
	assert(chest)

	local list  = inv:get_list("main")
	local count = 0
	local iname = nil

	for i=1, #list do
		if not list[i]:is_empty() then
			count = count + list[i]:get_count()

			assert(not iname or iname == list[i]:get_name())
			iname = list[i]:get_name()
		end
	end

	if chest.itemname then
		local old = self:get_item(chest.itemname)
		if old then
			old.stock = old.stock - chest.count
		end
	end

	chest.itemname = iname or chest.itemname
	chest.count    = count

	if chest.itemname then
		local new = self:get_item_or_make(chest.itemname)
		new.stock = new.stock + count
	end
end

function Shop:chest_add_item(pos, stack)
	local chest = self:get_chest(pos)
	assert(chest)

	chest.itemname = stack:get_name()
	chest.count    = chest.count + stack:get_count()

	local new = self:get_item_or_make(chest.itemname)
	new.stock = new.stock + stack:get_count()
end

function Shop:chest_remove_item(pos, stack)
	local chest = self:get_chest(pos)
	assert(chest)

	chest.count = chest.count - stack:get_count()

	local new = self:get_item_or_make(chest.itemname)
	new.stock = new.stock - stack:get_count()
end
