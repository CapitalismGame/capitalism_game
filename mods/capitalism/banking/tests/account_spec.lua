package.path = 'mods/?.lua;' ..
				package.path

_G.banking = {}
_G.audit = function()
	return { post = function() end }
end

require("capitalism/banking/account")

local Account = banking.Account

describe("account", function()
	it("withdraw", function()
		local acc = Account:new()
		acc.owner = "c:test"

		assert.equals(acc.balance, 0)
		assert.is_false(acc:withdraw(10, nil, nil))
		assert.equals(acc.balance, 0)

		acc.balance = 1000

		assert.is_true(acc:withdraw(10, nil, nil))
		assert.equals(acc.balance, 990)
	end)

	it("deposit", function()
		local acc = Account:new()
		acc.owner = "c:test"

		assert.equals(acc.balance, 0)
		assert.is_nil(acc:deposit(10, nil, nil))
		assert.equals(acc.balance, 10)
	end)
end)
