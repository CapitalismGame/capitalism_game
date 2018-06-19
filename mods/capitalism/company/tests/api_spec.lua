package.path = 'mods/?.lua;' ..
				package.path

_G.company = {}

require("libs/lib_underscore/init")
require("capitalism/company/api")
require("capitalism/company/company")

describe("company", function()
	it("register", function()
		local comp = company.Company:new()
		comp.name = "testcompany"
		comp.owner = "testuser"
		assert.is_true(company.register(comp.name, comp))
	end)

	it("get_by_name", function()
		local comp = company.get_by_name("testcompany")
		assert.is_not_nil(comp)
		assert.equals("testcompany", comp.name)
		assert.equals("testuser",    comp.owner)
	end)

	it("active_company", function()
		assert.is_nil  (company.get_active("testuser"))
		assert.is_false(company.set_active("testuser", "nonexistant"))
		assert.is_true (company.set_active("testuser", "testcompany"))

		local comp = company.get_active("testuser")
		assert.is_not_nil(comp)
		assert.equals("testcompany", comp.name)
		assert.equals("testuser",    comp.owner)
	end)

	it("get_companies_for_player", function()
		local comps = company.get_companies_for_player("testuser")
		assert.equals(1, #comps)
		assert.equals(company.get_by_name("testcompany"), comps[1])

		comps = company.get_companies_for_player("nonexistant")
		assert.equals(0, #comps)
	end)
end)
