audit = {}

function audit.make(_, area)
	local ret = {}

	function ret:post(username, comp, message)
		local cname = comp
		if type(cname) ~= "string" then
			cname = comp.name
		end

		minetest.log("action", "[" .. area .. "] " .. cname .. "/" .. username .. ": " .. message)
	end

	return ret
end

setmetatable(audit, {
	__call = audit.make
})
