--- Allows actions to be audited by companies
--
-- @module audit

--- audit table
audit = {}

--- Creates an `Auditor` object.
--
-- @function __call
-- @string area Area name
-- @usage local adt = audit("company")
--adt:pos(username, comp, message)
function audit.make(_, area)
	local ret = {}

	--- @type Auditor

	--- Log a message
	-- @function Auditor:post
	-- @string username
	-- @tparam company.Company|string comp
	-- @string message
	function ret:post(username, comp, message)
		local cname = comp
		if type(cname) ~= "string" then
			cname = comp and comp.name or "?"
		end

		minetest.log("action", "[" .. area .. "] " .. cname .. "/" .. username .. ": " .. message)
	end

	return ret
end

setmetatable(audit, {
	__call = audit.make
})
