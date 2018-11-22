package.path = 'mods/?.lua;' ..
				package.path

_G.company = {}
_G.banking = {}
_G.audit = function()
	return { post = function() end }
end

require("libs/lib_underscore/init")
require("capitalism/company/permissions")
require("capitalism/company/api")
require("capitalism/company/company")
require("capitalism/banking/api")
require("capitalism/banking/account")

local Account = banking.Account

describe("banking", function()
	it("add_account", function()
		local acc = Account:new()
		acc.owner = "c:test"

		assert.equals (#banking._accounts, 0)
		assert.is_nil (banking.get_by_owner("c:test"))
		assert.is_nil (banking.dirty)
		assert.equals (#banking._accounts, 0)
		assert.equals (banking.add_account(acc), acc)
		assert.equals (#banking._accounts, 1)
		assert.is_true(banking.dirty)
		assert.equals (banking.get_by_owner("c:test"), acc)
		assert.equals (#banking._accounts, 1)
	end)

	it("get_by_*", function()
		assert.equals(banking.get_by_company("test").owner, "c:test")
		assert.is_nil(banking.get_by_company("nonexistant"))
		assert.is_nil(banking.get_by_owner("nonexistant"))
		assert.is_nil(banking.get_by_owner("test"))
		assert.equals(banking.get_by_owner("c:test").owner, "c:test")
	end)

	it("get_balance", function()
		assert.equals(banking.get_balance("test"), 0)
		banking.get_by_company("test").balance = 100
		assert.equals(banking.get_balance("test"), 100)
	end)

	it("transfer", function()
		local acc2 = Account:new()
		acc2.owner = "c:two"

		assert.equals(banking.add_account(acc2), acc2)

		assert.equals(banking.get_balance("test"), 100)
		assert.equals(banking.get_balance("two"), 0)

		assert.is_false(banking.transfer("a", "c:two", "c:test", 40, nil))

		assert.equals(banking.get_balance("test"), 100)
		assert.equals(banking.get_balance("two"), 0)

		assert.is_true(banking.transfer("a", "c:test", "c:two", 40, nil))

		assert.equals(banking.get_balance("test"), 60)
		assert.equals(banking.get_balance("two"), 40)

		assert.is_false(banking.transfer("a", "c:two", "c:test", 70, nil))

		assert.equals(banking.get_balance("test"), 60)
		assert.equals(banking.get_balance("two"), 40)

		assert.is_true(banking.transfer("a", "c:two", "c:test", 10, nil))

		assert.equals(banking.get_balance("test"), 70)
		assert.equals(banking.get_balance("two"), 30)

		local comp = company.Company:new()
		comp:set_title_calc_name("Two")
		comp.owner = "testuser"
		company.add(comp)

		assert.is_false(banking.transfer("a", "c:two", "c:test", 10, nil))

		assert.equals(banking.get_balance("test"), 70)
		assert.equals(banking.get_balance("two"), 30)

		assert.is_false(banking.transfer("testuser", "c:two", "c:test", 10, nil))

		assert.equals(banking.get_balance("test"), 70)
		assert.equals(banking.get_balance("two"), 30)

		company.set_active("testuser", "two")
		assert.is_true(banking.transfer("testuser", "c:two", "c:test", 10, nil))

		assert.equals(banking.get_balance("test"), 80)
		assert.equals(banking.get_balance("two"), 20)
	end)
end)
