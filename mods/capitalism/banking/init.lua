local banking = {}

function banking.get_balance(comp)
	return 1000000
end


company.register_panel({
	title = "Finance",
	bgcolor = "#DAA520",
	get = function(_, comp, _)
		return "label[0.2,0.2;" .. minetest.formspec_escape("Balance: " .. banking.get_balance(comp)) .. "]"
	end,
})
