package.path = 'mods/?.lua;' ..
				package.path

_G.company = {}

require("capitalism/company/permissions")
require("capitalism/company/company")

local Company = company.Company
describe("company.Company", function()
	it("constructs", function()
		local company = Company:new()
		assert.is_nil(company.owner)
	end)

	it("has ownership", function()
		local company = Company:new()
		company.owner = "foobar"
		assert.equals(company:get_ownership("foobar"),     1)
		assert.equals(company:get_ownership("foobarasas"), 0)
		assert.equals(company:get_ownership("a"),          0)
		assert.equals(company:get_ownership("assd"),       0)
		assert.equals(company:get_ownership(nil),          0)
		assert.equals(company:get_ownership(""),           0)
	end)

	it("has ceo", function()
		local company = Company:new()
		company.owner = "foobar"
		assert.equals(company:get_ceo_name(), "foobar")
	end)

	it("can become active", function()
		local company = Company:new()
		assert.is_false(company:can_become_active("foobar"))
		company.owner = "foobar"
		assert.is_true (company:can_become_active("foobar"))
		assert.is_false(company:can_become_active("sdsddd"))
	end)

	it("has permissions", function()
		local company = Company:new()
		company.owner = "foobar"
		assert.is_true (company:check_perm("foobar", "SWITCH_TO"))
		assert.is_false(company:check_perm("sdsddd", "SWITCH_TO"))
	end)
end)
