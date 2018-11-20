package.path = 'mods/?.lua;' ..
				package.path

_G.company = {}

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

	it("has permissons", function()
		local company = Company:new()
		company.owner = "foobar"
		assert.is_true (company:check_perm("foobar", "anything"))
		assert.is_false(company:check_perm("sdsddd", "anything"))
	end)
end)
