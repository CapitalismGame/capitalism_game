package.path = 'mods/?.lua;' ..
				package.path

_G.company = {}
_G.audit = function()
	return { post = function() end }
end

require("libs/lib_underscore/init")
require("capitalism/company/api")
require("capitalism/company/company")

describe("company", function()
	it("register", function()
		local comp = company.Company:new()
		comp:set_title_calc_name("Test Company")
		comp.owner = "testuser"
		assert.is_true(company.register(comp))
		assert.equals("test_company", comp.name)
	end)

	it("get_by_name", function()
		local comp = company.get_by_name("test_company")
		assert.is_not_nil(comp)
		assert.equals("test_company", comp.name)
		assert.equals("testuser",     comp.owner)
	end)

	it("active_company", function()
		assert.is_nil  (company.get_active("testuser"))
		assert.is_false(company.set_active("testuser", "nonexistant"))
		assert.is_true (company.set_active("testuser", "test_company"))

		local comp = company.get_active("testuser")
		assert.is_not_nil(comp)
		assert.equals("test_company", comp.name)
		assert.equals("testuser",     comp.owner)
	end)

	it("get_companies_for_player", function()
		local comps = company.get_companies_for_player("testuser")
		assert.equals(1, #comps)
		assert.equals(company.get_by_name("test_company"), comps[1])

		comps = company.get_companies_for_player("nonexistant")
		assert.equals(0, #comps)
	end)
end)
