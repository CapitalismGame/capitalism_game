package.path = '../../?.lua;' .. -- tests root
			   '../?.lua;' .. -- mod root
				package.path

_G.company = {}

require("company/company")
local Company = company.Company
describe("Company", function()
	it("constructs", function()
		local company = Company:new()
		assert.equals(company.balance, 0)
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
		assert.is_true (company:check_user_permission("foobar", "anything"))
		assert.is_false(company:check_user_permission("sdsddd", "anything"))
	end)

    it("has balance", function()
        local company = Company:new()
        assert.equals(company:get_balance(), 0)
    end)
end)
