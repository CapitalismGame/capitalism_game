lib_utils = {}

function lib_utils.make_saveload(tab, storage, itemarraykey, registername, class)
	assert(tab)
	assert(storage)
	assert(itemarraykey)
	assert(registername)
	assert(class and class.new and class.from_table)

	tab.save = function()
		local res = _.map(tab[itemarraykey], function(item)
			return item:to_table()
		end)
		storage:set_string("version", 1)
		storage:set_string(itemarraykey, minetest.serialize(res))
	end

	tab.load = function()
		local table = minetest.deserialize(storage:get_string(itemarraykey)) or {}
		_.each(table, function(v)
			local obj = class:new()
			assert(obj:from_table(v))
			assert(tab[registername](obj))
		end)
	end
end
