local function flatten_list(list, level, out)
	if level == nil or out == nil then
		assert(level == nil and out == nil)
		level = 0
		out = {}
	end

	for i=1, #list do
		local area = list[i]

		local children = area.children
		-- area.children = nil
		area.level = level
		out[#out + 1] = area

		flatten_list(children, level + 1, out)
	end

	return out
end

local function build_list()
	local tree = land.get_area_tree()
	return flatten_list(tree)
end


land.show_debug_to = lib_quickfs.register("land:debug", {
	privs = { land_admin = true },

	get = function(context, player)
		local fs = {
			"size[7,6]",
			"tablecolumns[color;tree;text,width=10;text]",
			-- "tableoptions[background=#00000000;border=false]",
			"table[0,0;4.8,6;list_areas;"
		}

		local list = build_list()
		context.list = list

		if not context.selected then
			context.selected = 1
		elseif context.selected > #list then
			context.selected = #list
		end

		for i=1, #list do
			local area = list[i]

			if i > 1 then
				fs[#fs + 1] = ","
			end

			local lnd = land.get_by_area_id(area.id)
			local p_lnd = area.parent and land.get_by_area_id(area.parent)

			if lnd then
				if lnd.land_type == "commercial" then
					fs[#fs + 1] = "#69f,"
				elseif lnd.land_type == "industrial" then
					fs[#fs + 1] = "#f96,"
				elseif lnd.land_type == "residential" then
					fs[#fs + 1] = "#6f6,"
				else
					fs[#fs + 1] = "#000,"
				end
			elseif p_lnd then
				fs[#fs + 1] = ","
			else
				fs[#fs + 1] = "#999,"
			end

			fs[#fs + 1] = area.level .. "," ..
					minetest.formspec_escape(area.name .. " [id=" .. area.id .. "]") .. "," ..
					minetest.formspec_escape(area.owner)
		end

		fs[#fs + 1] = ";"
		if context.selected then
			fs[#fs + 1] = tostring(context.selected)
		end
		fs[#fs + 1] = "]"

		if context.selected then
			-- local area = list[context.selected]
			-- fs[#fs + 1] = "box[5,1;1.8,0.8;#222]"
			fs[#fs + 1] = "button[5,0;2,1;to_comm;Commercial]"
			fs[#fs + 1] = "button[5,1;2,1;to_inds;Industrial]"
			fs[#fs + 1] = "button[5,2;2,1;to_resd;Residential]"
			fs[#fs + 1] = "button[5,4;2,1;set_owner;Set Owner]"
			fs[#fs + 1] = "box[5,3;1.8,0.8;#222]"
			fs[#fs + 1] = "button[5,5;2,1;delete;Delete]"

		else
			fs[#fs + 1] = "label[0.1,6.1;No area selected]"
		end

		return table.concat(fs, "")
	end,

	on_receive_fields = function(context, player, fields)
		if fields["list_areas"] then
			local evt =  minetest.explode_table_event(fields["list_areas"])
			context.selected = evt.row
			return true
		end

		local function do_set_list(list, type)
			for i=1, #list do
				local id       = list[i].id
				local area     = areas.areas[id]
				area.land_type = type
				do_set_list(list[i].children, type)
			end
		end

		local function do_set(type)
			do_set_list({ context.list[context.selected] }, type)
			areas:save()

			return true
		end

		if context.selected then
			if fields.to_comm then
				return do_set("commercial")
			elseif fields.to_inds then
				return do_set("industrial")
			elseif fields.to_resd then
				return do_set("residential")
			elseif fields.unzone then
				local area = context.list[context.selected]
				land.remove_zone(area.id)
				return true
			end
		end
	end,
})

land.show_set_price_to = lib_quickfs.register("land:set_price", {
	check = function(context, player, area)
		return land.can_set_price(area, player:get_player_name())
	end,

	get = function(context, player, area)
		assert(area.owner and area.pos2)
		local fs = {
			"size[3,2]",
			"field[0.3,0.5;3,1;price;Price;", tostring(area.land_sale), "]",
			"button_exit[1,1.2;1,1;set;Set]"
		}

		return table.concat(fs, "")
	end,

	on_receive_fields = function(context, player, fields, area)
		if fields.set then
			land.set_price(area, player:get_player_name(),
					tonumber(fields.price) or 100000)
		end
	end,
})


land.show_buy_to = lib_quickfs.register("land:buy", {
	check = function(context, player, area)
		return area ~= nil
	end,

	get = function(context, player, area)
		local pname = context.pname
		assert(area.owner and area.pos2)
		assert(area.land_sale)

		local price_changed = context.price and context.price ~= area.land_sale
		context.price = area.land_sale

		local fs = {
			"size[5,2.4]",
			company.get_company_header(pname, 5, "balance"),
			"box[-0.3,1.15;5.4,0.4;",
			price_changed and "#f00" or "#111",
			"]label[0,1.1;",
			minetest.formspec_escape(
				(price_changed and "Price changed:" or "For sale for ") ..
					area.land_sale),
			"]",
		}

		local comp     = company.get_active(pname)
		local suc, msg = land.can_buy(area, pname, comp)
		if suc then
			fs[#fs + 1] = "button_exit[0.5,1.7;2,1;back;Back]"
			fs[#fs + 1] = "button_exit[2.5,1.7;2,1;buy;Buy]"
		else
			fs[#fs + 1] = "box[-0.3,1.55;5.4,1.3;#f00]"
			fs[#fs + 1] = "label[0,1.8;" .. msg .. "]"
		end

		return table.concat(fs, "")
	end,

	on_receive_fields = function(context, player, fields, area)
		if fields.switch then
			company.show_company_select_dialog(player:get_player_name(), function(player2)
				land.show_buy_to(player2:get_player_name(), unpack(context.args))
			end)
		end

		if fields.buy then
			if context.price ~= area.land_sale then
				return true
			end
			land.buy(area, player:get_player_name())
		end
	end,
})


company.register_panel({
	title = "Land",
	bgcolor = "#A0522D",
	get = function(_, _, comp, _)
		local areas = land.get_all(comp.name)

		local sums   = {}
		for i=1, #areas do
			local key = areas[i].land_type
			sums[key] = (sums[key] or 0) + 1
		end

		local text  = "Total: " .. #areas
		for key, value in pairs(sums) do
			text = text .. "\n" .. key .. ": " .. value
		end

		return "label[0.2,0.2;" .. minetest.formspec_escape(text) .. "]"
	end,
})
