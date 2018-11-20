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


land.show_debug_to = lib_quickfs.register("land:debug", function(self, playername)
		local fs = {
			"size[7,6]",
			"tablecolumns[color;tree;text,width=10;text]",
			-- "tableoptions[background=#00000000;border=false]",
			"table[0,0;4.8,6;list_areas;"
		}

		local list = build_list()
		self.list = list

		if not self.selected then
			self.selected = 1
		elseif self.selected > #list then
			self.selected = #list
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
		if self.selected then
			fs[#fs + 1] = tostring(self.selected)
		end
		fs[#fs + 1] = "]"

		if self.selected then
			-- local area = list[self.selected]
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
	function(self, player, formname, fields)
		if fields["list_areas"] then
			local evt =  minetest.explode_table_event(fields["list_areas"])
			self.selected = evt.row
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
			do_set_list({ self.list[self.selected] }, type)
			areas:save()

			return true
		end

		if self.selected then
			if fields.to_comm then
				return do_set("commercial")
			elseif fields.to_inds then
				return do_set("industrial")
			elseif fields.to_resd then
				return do_set("residential")
			elseif fields.unzone then
				local area = self.list[self.selected]
				land.remove_zone(area.id)
				return true
			end
		end
	end, { land_admin = true })


company.register_panel({
	title = "Land",
	bgcolor = "#A0522D",
	get = function(_, _, _)
		return "label[0.2,0.2;" .. minetest.formspec_escape("Total: 1 ($100,000)\nCommercial: 1 ($100,000)\nIndustrial: 0 ($0)") .. "]"
	end,
})
