package.path = "cash/tests/?.lua;" .. -- tests root
		"cash/?.lua;" .. -- mod root
		package.path

function _G.ItemStack(name)
	return {
		get_name = function(self)
			return name
		end
	}
end

require("api")
require("items")

describe("cash", function()
	describe("change", function()
		it("1.43", function()
			local res = cash.get_change(1.43)
			assert(res)
			local expected = {
				ItemStack("cash:coin_100"),
				ItemStack("cash:coin_10"),
				ItemStack("cash:coin_10"),
				ItemStack("cash:coin_10"),
				ItemStack("cash:coin_10"),
				ItemStack("cash:coin_1"),
				ItemStack("cash:coin_1"),
				ItemStack("cash:coin_1"),
			}
			assert(#res == #expected)
			for i = 1, #res do
				assert(res[i]:get_name() == expected[i]:get_name())
			end
		end)

		it("1.65", function()
			local res = cash.get_change(1.65)
			assert(res)
			local expected = {
				ItemStack("cash:coin_100"),
				ItemStack("cash:coin_50"),
				ItemStack("cash:coin_10"),
				ItemStack("cash:coin_1"),
				ItemStack("cash:coin_1"),
				ItemStack("cash:coin_1"),
				ItemStack("cash:coin_1"),
				ItemStack("cash:coin_1"),
			}
			assert(#res == #expected)
			for i = 1, #res do
				assert(res[i]:get_name() == expected[i]:get_name())
			end
		end)
	end)
end)
