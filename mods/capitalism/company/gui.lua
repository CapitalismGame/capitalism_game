company.show_company_select_dialog = lib_quickfs.register("company:set_company", {
	get = function(context, player)
		local pname   = player:get_player_name()
		local comps   = company.get_companies_for_player(pname)
		context.comps = _.map(comps, function(comp)
			return comp.name
		end)

		local formspec
		if #comps == 0 then
			formspec = {
				"size[4,5]",
				"label[0,-0.1;You're not a member of any companies]",
			}
		else
			formspec = {
				"size[4,5]",
				"label[0,-0.1;Select a Company]",
				"textlist[-0.1,0.5;4,4;companies;",
				table.concat(_.map(comps, function(comp)
					if comp:get_ceo_name() == pname then
						return minetest.formspec_escape(comp.title)
					else
						return minetest.formspec_escape(minetest.colorize("#c0c0c0", comp.title))
					end
				end), ","),
				";1;false]",
				"button[0,4.5;2,1;back;Back]",
				"button[2,4.5;2,1;switch;Switch]",
			}
		end

		return table.concat(formspec, "")
	end,

	on_receive_fields = function(context, player, fields)
		if fields.companies then
			local evt = minetest.explode_textlist_event(fields.companies)
			if evt.type == "CHG" then
				context.idx = evt.index
			end
		end

		local ret = context.args[1]

		local name = player:get_player_name()
		if fields.switch and context.comps then
			local comp_name = context.comps[context.idx or 1]
			company.set_active(name, comp_name)
			ret(player)
		elseif not (fields.quit ~= "" or fields.back) then
			ret(player)
			return
		end
	end,
})


company.show_company_house = lib_quickfs.register("company:house", {
	check = function(context, player, comp)
		return company.check_perm(player:get_player_name(), comp.name, "EDIT_DETAILS")
	end,

	get = function(context, player, comp)
		local pname = player:get_player_name()
		if not comp then
			context.is_new = true
		end

		local data = context.data
		if not data then
			data = {
				name  = comp and comp.name:sub(3, #comp.name) or "",
				title = comp and comp.title or "",
			}
			context.data = data
		end

		local fs = {
			"size[6,5.1]",
			company.get_company_header(pname, 6, 4.1),
			"field[0.3,2.1;6,1;title;Title;", minetest.formspec_escape(data.title), "]",
			"button[1,3.5;2,1;cancel;Cancel]",
			"button[3,3.5;2,1;save;Save]",
		}

		if context.error then
			fs[#fs + 1] = "box[-0.3,3.05;6.4,0.4;#f00]"
			fs[#fs + 1] = "label[0,3;"
			fs[#fs + 1] = minetest.formspec_escape(context.error)
			fs[#fs + 1] = "]"

			context.error = nil
		end

		if context.is_new then
			fs[#fs + 1] = "field[0.3,0.6;6,1;name;Name;"
			fs[#fs + 1] = minetest.formspec_escape(data.name)
			fs[#fs + 1] = "]"
		else
			fs[#fs + 1] = "label[0,0;Name]"
			fs[#fs + 1] = "label[0.05,0.5;"
			fs[#fs + 1] = minetest.formspec_escape(data.name)
			fs[#fs + 1] = "]"
			fs[#fs + 1] = "box[0,0.4;5.8,0.66;#111]"
		end

		return table.concat(fs, "")
	end,

	on_receive_fields = function(context, player, fields, comp)
		if fields.switch then
			company.show_company_select_dialog(player:get_player_name(), function(player2)
				local pname = player2:get_player_name()
				company.show_company_house(pname, comp and company.get_active(pname))
			end)
			return false
		end

		local data = context.data
		if not data then
			return
		end

		if fields.name and context.is_new then
			if not company.check_name then
				context.error = "Only lowercase letters allowed in name"
			end
			data.name = company.check_name("c:" .. fields.name)
		end

		if context.error then
			return true
		end
	end,
})


function company.get_company_header(pname, width, y, snippet)
	local comp = company.get_active(pname)
	local func = company.registered_snippets[snippet or "ceo"]
	assert(func, "Unable to find snippet " .. (snippet or "ceo"))

	local snippet_text = ""
	if comp and func then
		snippet_text = minetest.formspec_escape(func(comp))
	end

	return table.concat({
			"container[0,", tostring(y + 0.45), "]",
			"box[-0.3,-0.1;", tostring(width + 0.4), ",1.1;#222]",
			"label[0.1,0.0;",
			minetest.formspec_escape(comp and comp.title or "No active company"),
			"]",
			"label[0.1,0.4;",
			snippet_text,
			"]",
			"button[",
			tostring(width - 2),
			",0;2,1;switch;Switch]",
			"container_end[]",
		}, "")
end

sfinv.register_page("company:company", {
	title = "Company",
	get = function(self, player, context)
		local pname = player:get_player_name()
		local comp  = company.get_active(pname)

		-- Using an array to build a formspec is considerably faster
		local formspec = {
			company.get_company_header(pname, 8, 7.6)
		}

		if comp then
			local i = 0
			for _, panel in pairs(company.registered_panels) do
				if not panel.show_to or panel:show_to(player, comp, context) then
					formspec[#formspec + 1] = "container["
					formspec[#formspec + 1] = tostring((i % 2) * 4)
					formspec[#formspec + 1] = ","
					formspec[#formspec + 1] = tostring(math.floor(i / 2) * 2)
					formspec[#formspec + 1] = ".3]"

					formspec[#formspec + 1] = "label[1.5,-0.3;"
					formspec[#formspec + 1] = panel.title
					formspec[#formspec + 1] = "]"

					formspec[#formspec + 1] = "box[0,-0.3;3.8,1.8;"
					formspec[#formspec + 1] = panel.bgcolor
					formspec[#formspec + 1] = "]"

					formspec[#formspec + 1] = panel:get(player, comp, context)
					formspec[#formspec + 1] = "container_end[]"

					i = i + 1
				end
			end

			while i < 2*4 do
				formspec[#formspec + 1] = "box["
				formspec[#formspec + 1] = tostring((i % 2) * 4)
				formspec[#formspec + 1] = ","
				formspec[#formspec + 1] = tostring(math.floor(i / 2) * 2)
				formspec[#formspec + 1] = ";3.8,1.8;#111]"

				i = i + 1
			end
		end

		-- Wrap the formspec in sfinv's layout (ie: adds the tabs and background)
		return sfinv.make_formspec(player, context,
				table.concat(formspec, ""), false)
	end,
	on_player_receive_fields = function(self, player, context, fields)
		if fields.switch then
			company.show_company_select_dialog(player:get_player_name(), function(player2)
				sfinv.set_page_and_show(player2, "company:company")
			end)
			return true
		end

		local comp = company.get_active(player:get_player_name())
		if not comp then
			return false
		end

		for _, panel in pairs(company.registered_panels) do
			if (not panel.show_to or panel:show_to(player, comp, context)) and
					panel.on_player_receive_fields and
					panel.on_player_receive_fields(player, context, fields) then
				return true
			end
		end
	end,
})

-- Place company page at front
table.insert(sfinv.pages_unordered, 1, sfinv.pages["company:company"])
table.remove(sfinv.pages_unordered, #sfinv.pages_unordered)


company.register_snippet("ceo", function(comp)
	return comp and ("CEO: " .. comp:get_ceo_name()) or ""
end)

company.register_panel({
	title = "Company House",
	bgcolor = "#369",
	get = function(_, _, _, _)
		return "button[1,0.6;2,1;edit_details;Edit Details]"
	end,
	on_player_receive_fields = function(player, context, fields)
		if fields.edit_details then
			local pname = player:get_player_name()
			local comp  = company.get_active(pname)
			if comp then
				company.show_company_house(player:get_player_name(), comp)
				return true
			end
		end
	end,
})

company.register_panel({
	title = "Members",
	bgcolor = "#396",
	get = function(_, _, comp, _)
		local memcount       = 0
		for username, props in pairs(comp.members) do
			memcount = memcount + 1
		end

		return "label[0.2,0.2;" .. memcount .. " members]"
	end,
})

function sfinv.get_homepage_name(player)
	return "company:company"
end
