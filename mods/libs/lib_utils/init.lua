lib_utils = {}

function lib_utils.make_saveload(tab, storage, itemarraykey, registername, class)
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
			tab[registername](obj.name, obj)
		end)
	end
end
