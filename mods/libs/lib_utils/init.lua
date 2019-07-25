lib_utils = {}

function lib_utils.interval(time, func, ...)
	local function tick(...)
		func(...)
		minetest.after(time, tick, ...)
	end
	minetest.after(time, tick, ...)
end

function lib_utils.make_saveload(tab, storage, itemarraykey, registername, class)
	assert(tab)
	assert(storage)
	assert(itemarraykey)
	assert(registername)
	assert(class and class.new and class.from_table)

	tab.__saves = tab.__saves or {}
	tab.__loads = tab.__loads or {}
	tab.dirty = false

	table.insert(tab.__saves, function()
		local res = _.map(tab[itemarraykey], function(item)
			return item:to_table()
		end)
		storage:set_string("version", 1)
		storage:set_string(itemarraykey, minetest.serialize(res))
	end)

	table.insert(tab.__loads, function()
		local table = minetest.deserialize(storage:get_string(itemarraykey)) or {}
		_.each(table, function(v)
			local obj = class:new()
			assert(obj:from_table(v))
			assert(tab[registername](obj))
		end)
	end)

	if not tab.save then
		local function step()
			if tab.dirty then
				tab.save()
			end

			minetest.after(20, step)
		end

		minetest.after(math.random(5,13), step)
		minetest.register_on_shutdown(function() tab.save() end)
	end

	tab.save = function()
		for _, func in pairs(tab.__saves) do
			func()
		end

		tab.dirty = false
	end

	tab.load = function()
		for _, func in pairs(tab.__loads) do
			func()
		end

		tab.dirty = false
	end
end

function vector.sqdist(a, b)
	local x = a.x - b.x
	local y = a.y - b.y
	local z = a.z - b.z
	return x*x + y*y + z*z
end
