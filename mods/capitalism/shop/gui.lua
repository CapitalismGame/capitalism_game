function shop.show_shop_form(pname, pos)
	if shop.can_admin(pname, pos) then
		shop.show_admin_form(pname, pos)
	else
		minetest.chat_send_player(pname, "Shop checkout unimplemented")
		-- shop.show_shop_checkout_form(playername, pos)
	end
end


shop.show_admin_form = lib_quickfs.register("shop:counter_admin", {
	check = function(context, player, pos)
		return shop.can_admin(player:get_player_name(), pos)
	end,

	get = function(context, player, pos)
		local s = shop.get_by_pos(pos)
		assert(s)

		local fs = {
			"size[7,7]",
			"label[0,0;",
			minetest.formspec_escape(s.name),
			"]",
			"dropdown[3,0;4;a;Open;1]",
			"tablecolumns[color;text;text;text;text]",
			-- "tableoptions[background=#00000000;border=false]",
			"table[0,1;4.8,6;list_items;",
			"#999,Description,Stock,Price,Sales",
		}

		-- Description Stock PricePI Sold

		local items_kv = s:get_items()
		local items    = {}
		context.items  = items
		for _, item in pairs(items_kv) do
			local def  = minetest.registered_items[item.name] or {}
			local desc = def.description or item.name

			items[#items + 1] = item

			fs[#fs + 1] = ",,"
			fs[#fs + 1] = desc
			fs[#fs + 1] = ","
			fs[#fs + 1] = item.stock
			fs[#fs + 1] = ","
			fs[#fs + 1] = (item.price >= 0) and item.price or "-"
			fs[#fs + 1] = ","
			fs[#fs + 1] = item.sold
		end

		if next(items) and not context.selected then
			context.selected = 1
		end

		if context.selected then
			if context.selected > #items then
				 context.selected = #items
			end

			if context.selected and context.selected > 0 then
				fs[#fs + 1] = ";"
				fs[#fs + 1] = tostring(context.selected + 1)
			end
		end

		fs[#fs + 1] = "]"

		if context.selected and context.selected > 0 then
			local item = items[context.selected]

			fs[#fs + 1] = "field[5.3,1.3;2,1;price;;"
			fs[#fs + 1] = item.price
			fs[#fs + 1] = "]"
			fs[#fs + 1] = "button[5,2;2,1;set_price;Set Price]"
			fs[#fs + 1] = "box[5,3;1.8,0.8;#222]"
			fs[#fs + 1] = "box[5,4;1.8,0.8;#222]"
			fs[#fs + 1] = "box[5,5;1.8,0.8;#222]"
			fs[#fs + 1] = "box[5,6;1.8,0.8;#222]"
		else
			fs[#fs + 1] = "box[5,1;1.8,0.8;#222]"
			fs[#fs + 1] = "box[5,2;1.8,0.8;#222]"
			fs[#fs + 1] = "box[5,3;1.8,0.8;#222]"
			fs[#fs + 1] = "box[5,4;1.8,0.8;#222]"
			fs[#fs + 1] = "box[5,5;1.8,0.8;#222]"
			fs[#fs + 1] = "box[5,6;1.8,0.8;#222]"
		end

		return table.concat(fs, "")
	end,

	on_receive_fields = function(context, player, fields, pos)
		if fields.list_items then
			local evt =  minetest.explode_table_event(fields.list_items)
			context.selected = evt.row - 1
			return true
		end

		if fields.set_price then
			local item  = context.items[context.selected]
			if item then
				item.price = tonumber(fields.price) or -1
			end
			shop.dirty = true
			return true
		end
	end,
})


shop.show_chest_form = lib_quickfs.register("shop:chest", {
	check = function(context, player, s, pos)
		local area = land.get_by_pos(pos)
		return area and company.check_perm(context.pname, area.owner,
				"SHOP_CHEST", { area = area })
	end,

	get = function(context, player, s, pos)
		local inv = minetest.get_inventory({ type = "node", pos = pos })
		s:chest_poll(pos, inv)

		local title = "Unassigned chest"
		local chest = s:get_chest(pos)
		if chest.itemname then
			local def = minetest.registered_items[chest.itemname] or {}
			title     = def.description or chest.itemname

			local item = s:get_item(chest.itemname)
			if item.price >= 0 then
				title = title .. " ($" .. item.price .. ")"
			else
				title = title .. " (not for sale)"
			end
		end

		local spos = pos.x .. "," .. pos.y .. "," .. pos.z
		local fs = {
			"size[8,7.3]",
			default.gui_slots,
			"label[0,0;", minetest.formspec_escape(title), "]",
			"button[6,0.3;2,0;overview;Shop Overview]",
			"list[nodemeta:", spos, ";main;0,0.9;8,2;]",
			"list[current_player;main;0,3.25;8,1;]",
			"list[current_player;main;0,4.48;8,3;8]",
			"listring[nodemeta:", spos, ";main]",
			"listring[current_player;main]",
			default.get_hotbar_bg(0, 3.25)
		}

		if chest.itemname then
			fs[#fs + 1] = "button[4,0.3;2,0;unassign;Unassign]"
		end

		return table.concat(fs, "")
	end,

	on_receive_fields = function(context, player, fields)
		if fields.unassign then
			local s     = context.args[1]
			local pos   = context.args[2]

			shop.unassign_chest(s, pos, player:get_inventory())
			return true
		end

		if fields.overview then
			shop.show_admin_form(player:get_player_name(), context.args[2])
			return false
		end
	end,
})
