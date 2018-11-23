function shop.show_shop_form(pname, pos)
	if shop.can_admin(pname, pos) then
		shop.show_admin_form(pname, pos)
	else
		minetest.chat_send_player(pname, "Shop checkout unimplemented")
		-- shop.show_shop_checkout_form(playername, pos)
	end
end

shop.show_admin_form = lib_quickfs.register("shop:counter_admin", function(context, pname, pos)
		assert(shop.can_admin(pname, pos))

		local fs = {
			"size[4,6]",
			"tablecolumns[color;text;text;text;text]",
			-- "tableoptions[background=#00000000;border=false]",
			"table[0,0;4,6;list_items;",
			"#999,Description,Stock,Price,Sales",
		}

		-- Description Stock PricePI Sold

		local s = shop.get_by_pos(pos)
		assert(s)

		for _, item in pairs(s:get_items()) do
			fs[#fs + 1] = ",,"
			fs[#fs + 1] = item.description
			fs[#fs + 1] = ","
			fs[#fs + 1] = item.stock
			fs[#fs + 1] = ","
			fs[#fs + 1] = item.price
			fs[#fs + 1] = ","
			fs[#fs + 1] = item.sold
		end

		fs[#fs + 1] = "]"

		return table.concat(fs, "")
	end,
	function(context, player, formname, fields)

	end)
