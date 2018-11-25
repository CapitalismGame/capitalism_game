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

function company.get_company_header(pname, width, mode)
	local comp = company.get_active(pname)

	local second = ""
	if comp and mode == "balance" then
		second = "Balance: " .. banking.get_balance(comp)
	elseif comp then
		second = "CEO: " .. comp:get_ceo_name()
	end

	return table.concat({
			"label[0.1,0.0;",
			minetest.formspec_escape(comp and comp.title or "No active company"),
			"]",
			"label[0.1,0.4;",
			minetest.formspec_escape(second),
			"]",
			"button[",
			tostring(width - 2),
			",0;2,1;switch;Switch]",
		}, "")
end

sfinv.register_page("company:company", {
	title = "Company",
	get = function(self, player, context)
		local pname = player:get_player_name()
		local comp  = company.get_active(pname)

		-- Using an array to build a formspec is considerably faster
		local formspec = {
			company.get_company_header(pname, 8)
		}

		if comp then
			local i = 0
			for _, panel in pairs(company.registered_panels) do
				if not panel.show_to or panel:show_to(player, comp, context) then
					formspec[#formspec + 1] = "container["
					formspec[#formspec + 1] = tostring((i % 2) * 4)
					formspec[#formspec + 1] = ","
					formspec[#formspec + 1] = tostring(math.floor(i / 2) * 2 + 1)
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
				formspec[#formspec + 1] = tostring(math.floor(i / 2) * 2 + 1)
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
		end
	end,
})

-- Place company page at front
table.insert(sfinv.pages_unordered, 1, sfinv.pages["company:company"])
table.remove(sfinv.pages_unordered, #sfinv.pages_unordered)

company.register_panel({
	title = "Company House",
	bgcolor = "#369",
	get = function(_, _, _, _)
		return ""
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
