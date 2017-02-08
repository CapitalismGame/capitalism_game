cash = {
	_denoms
}

-- Register a cash thing
function cash.register(name, def)
	assert(def.groups and def.groups.money > 0)
	def.name = name
	table.insert(cash._denoms, def)
	return minetest.register_craftitem(name, def)
end

-- Work out the change that should be given
--
-- @param amount The amount to make up
-- @param available A key-value dictionary of available currency
-- @return An array of ItemStacks or nil
function cash.get_change(amount, available)
	if amount == 0 then
		return {}
	end
	local denoms = cash._denoms
	local ret = {}
	for _, def in ipairs(denoms) do
		while amount >= def.groups.money and (not available or available[def.name] > 0) do
			ret[#ret + 1] = ItemStack(def.name)
			amount = amount - def.groups.money
			if available then
				available[def.name] = available[def.name] - 1
			end
		end
		if amount == 0 then
			return ret
		end
	end

	-- Unable to make Currency
	return nil
end
