package.path = 'mods/?.lua;' ..
				package.path

_G.company = {}
_G.audit = function()
	return { post = function() end }
end

require("libs/lib_underscore/init")
require("capitalism/company/permissions")
require("capitalism/company/api")
require("capitalism/company/company")

describe("company", function()
	it("add", function()
		local comp = company.Company:new()
		comp:set_title_calc_name("Test Company")
		comp.ceo = "testuser"
		assert.equals (#company._companies, 0)
		assert.is_true(company.add(comp))
		assert.equals (#company._companies, 1)
		assert.equals ("c:test_company", comp.name)
	end)

	it("get_by_name", function()
		local comp = company.get_by_name("c:test_company")
		assert.is_not_nil(comp)
		assert.equals("c:test_company", comp.name)
		assert.equals("testuser",     comp.ceo)
	end)

	it("active_company", function()
		assert.is_nil  (company.get_active("testuser"))
		assert.is_false(company.set_active("testuser", "c:nonexistant"))
		assert.is_true (company.set_active("testuser", "c:test_company"))

		local comp = company.get_active("testuser")
		assert.is_not_nil(comp)
		assert.equals("c:test_company", comp.name)
		assert.equals("testuser",     comp.ceo)
	end)

	it("get_companies_for_player", function()
		local comps = company.get_companies_for_player("testuser")
		assert.equals(1, #comps)
		assert.equals(company.get_by_name("c:test_company"), comps[1])

		comps = company.get_companies_for_player("nonexistant")
		assert.equals(0, #comps)
	end)

	it("check_perm", function()
		assert.is_false(company.check_perm("baduser", "c:test_company", "SWITCH_TO", nil))
		assert.errors(function() company.check_perm("baduser", "nonexistant", "SWITCH_TO", nil) end)
		assert.is_true(company.check_perm("testuser", "c:test_company", "SWITCH_TO", nil))
	end)
end)
