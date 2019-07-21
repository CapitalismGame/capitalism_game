company.register_snippet("balance", function(comp)
	return "Balance: " .. banking.get_balance(comp)
end)


company.register_panel({
	title = "Finance",
	bgcolor = "#DAA520",
	get = function(_, _, comp, _)
		return "label[0,0.3;" .. minetest.formspec_escape("Balance: " .. banking.get_balance(comp)) .. "]"
	end,
})
