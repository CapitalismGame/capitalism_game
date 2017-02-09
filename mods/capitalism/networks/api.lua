networks = {
	_coms_map = {},
}

local function copy_pos(pos)
	return { x = pos.x, y = pos.y, z = pos.z }
end

function networks.init()
	networks.load()
end

function networks.load()
	local file = io.open(minetest.get_worldpath() .. "/networks.lua", "r")
	if file then
		local table = minetest.deserialize(file:read("*all"))
		if type(table) == "table" then
			assert(table.version_min <= 1, "Unsupported serialization")
			networks._coms_map = table.coms
		end
	end
end

function networks.save()
	local file = io.open(minetest.get_worldpath() .. "/networks.lua", "w")
	if file then
		file:write(minetest.serialize({
			version = 1,
			version_min = 1,
			coms = networks._coms_map
		}))
		file:close()
	end
end

-- Make a note of the location of a communicator node
function networks.add_coms(pos, companyname, placername)
	local def = {
		pos = copy_pos(pos),
		companyname = companyname,
		placername  = placername,
		senders     = {},
		receivers   = {}
	}

	networks._coms_map[minetest.pos_to_string(pos, 0)] = def
	networks.save()
end

-- Get a communicator definition table from position
function networks.get_coms(pos)
	return networks._coms_map[minetest.pos_to_string(pos, 0)]
end

function networks.do_connect(pos, compos, companyname, as)
	local def = minetest.registered_nodes[minetest.get_node(compos).name]
	assert(def, "bad nodedef in networks.do_connect")
	assert(def.groups and def.groups.communicator, "node not a communicator")

	if as then
		assert(def["on_" .. as .. "_connected"], "unsupported type " .. as)
		def["on_" .. as .. "_connected"](compos, pos)
	else
		def.on_receiver_connected(compos, pos)
		def.on_sender_connected(compos, pos)
	end
	networks.save()
end

function networks.find_near_and_connect(pos, companyname, as, radius)
	local res = minetest.find_node_near(pos, radius or 25, "group:communicator")
	if res then
		networks.do_connect(pos, res, companyname, as)
		return res
	end
	return nil
end
