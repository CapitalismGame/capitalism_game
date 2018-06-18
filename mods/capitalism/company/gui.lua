company.show_company_select_dialog =
	lib_quickfs.register("company:set_company", function(context, name)
		local comps   = company.get_companies_for_player(name)
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
					if comp:get_primary_owner() == name then
						return minetest.formspec_escape(comp.name)
					else
						return minetest.formspec_escape(minetest.colorize("#c0c0c0", comp.name))
					end
				end), ","),
				";1;false]",
				"button[0,4.5;2,1;back;Back]",
				"button[2,4.5;2,1;switch;Switch]",
			}
		end

		return table.concat(formspec, "")
	end,
	function(context, player, formname, fields)
		if fields.companies then
			local evt = minetest.explode_textlist_event(fields.companies)
			if evt.type == "CHG" then
				context.idx = evt.index
			end
		end

		local name = player:get_player_name()
		if fields.switch and context.comps then
			local comp_name = context.comps[context.idx or 1]
			company.set_active_company(name, comp_name)
		elseif not fields.quit then
			return
		end

		sfinv.set_page(player, "company:company")
		local fs = sfinv.get_formspec(player, sfinv.get_or_create_context(player))
		minetest.show_formspec(name, "", fs)
	end)

sfinv.register_page("company:company", {
	title = "Company",
	get = function(self, player, context)
		local comp = company.get_active_company(player:get_player_name())

		-- Using an array to build a formspec is considerably faster
		local formspec = {
			"label[0.1,0.0;",
			minetest.formspec_escape(comp and comp.name or "No active company"),
			"]",
			"label[0.1,0.4;",
			minetest.formspec_escape(comp and ("CEO: " .. comp:get_primary_owner()) or ""),
			"]",
			"button[6,0;2,1;switch;Switch]"
		}

		-- Wrap the formspec in sfinv's layout (ie: adds the tabs and background)
		return sfinv.make_formspec(player, context,
				table.concat(formspec, ""), false)
	end,
	on_player_receive_fields = function(self, player, context, fields)
		company.show_company_select_dialog(player:get_player_name())
	end,
})

table.insert(sfinv.pages_unordered, 1, sfinv.pages["company:company"])
table.remove(sfinv.pages_unordered, #sfinv.pages_unordered)
