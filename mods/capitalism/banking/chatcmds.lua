minetest.register_privilege("banking_admin", {
	give_to_singleplayer = false,
})

ChatCmdBuilder.new("banking", function(cmd)
	cmd:sub("give :owner :amount:int", function(name, owner, amount)
		if not minetest.check_player_privs(name, { banking_admin = true }) then
			return false, "Missing privilege: banking_admin"
		end

		owner = owner:lower()

		local acc = banking.get_by_owner(owner)
		if not acc then
			return false, "No accounts owned by " .. owner .. " (did you forget c:?)"
		end

		acc.balance = acc.balance + amount
		return true, "Gave " .. acc.balance .. " to " .. owner
	end)

	cmd:sub("transfer :to :amount:int :reason:text", function(name, to, amount, reason)
		local comp = company.get_active(name)
		if not comp then
			return false, "You need to select a company to operate as using /company use <name>"
		end

		if not banking.get_by_owner(to) then
			return false, "Unable to find an account for " .. to
		end

		local suc, msg = banking.transfer(name, "c:" .. comp.name, to, amount, reason)
		return suc, suc and "Transfered" or msg
	end)
end, {
	description = "Banking tools"
})
