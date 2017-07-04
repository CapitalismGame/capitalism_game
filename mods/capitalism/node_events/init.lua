node_events = {
	registered_sources = {},
	listener = {},
}

local function copy_pos(pos)
	return { x = pos.x, y = pos.y, z = pos.z }
end

function node_events.listener:new(name, pos, type)
	return setmetatable({
		name = name,
		pos = pos,
		type = type,
	}, { __index = node_events.listener })
end

function node_events.listener:on_msg(self, sender_pos, msg)
	local def = minetest.registered_nodes[self.name]
	return def[self.type](self.pos, sender_pos, msg)
end

function node_events.get_listeners_of(pos, type)
	print("[node_events] Getting listeners of source: " .. minetest.pos_to_string(pos))
	local source = node_events.registered_sources[minetest.pos_to_string(pos)]
	return source[type] or {}
	-- for i = 1, #res do
	-- 	local listener = res[i]
	-- 	res[i] = node_events.listener:new(listener.name, listener.pos, listener.type)
	-- end
	-- return res
end

-- Register a source
--
-- @param pos Position of source
-- @param types Array of acceptable types
function node_events.register_source(pos, types)
	local source = { pos = copy_pos(pos) }
	for _, type in ipairs(types) do
		source[type] = {}
	end

	node_events.registered_sources[minetest.pos_to_string(pos)] = source
end

function node_events.broadcast(pos, type, msg)
	local listeners = node_events.get_listeners_of(pos, type)
	for _, listeners in ipairs(listeners) do
		listeners:on_msg(pos, msg)
	end
end
