local function flatten_list(list, level, out)
	if level == nil or out == nil then
		assert(i == nil and out == nil)
		level = 0
		out = {}
	end

	for i=1, #list do
		local area = list[i]

		local children = area.children
		area.children = nil
		area.level = level
		out[#out + 1] = area

		flatten_list(children, level + 1, out)
	end

	return out
end

local function build_list(list)
	list = table.copy(list)

	local root = {}
	local item_by_id = {}
	local pending_by_id = {}

	for i=1, #list do
		local area    = list[i]
		area.id       = i
		area.children = {}

		if not area.parent then
			root[#root + 1] = area

			if pending_by_id[i] then
				area.children = pending_by_id
				pending_by_id[i] = nil
			end

		elseif item_by_id[area.parent] then
			local children = item_by_id[area.parent].children
			children[#children + 1] = area

		else
			pending_by_id[area.parent] = pending_by_id[area.parent] or {}
			local pending = pending_by_id[area.parent]
			pending[#pending + 1] = area
		end

		item_by_id[i]   = area
	end

	return flatten_list(root)
end


land.show_debug_to = lib_quickfs.register("land:debug", function(self, playername)
		local fs = {
			"size[5,6.8]",
			"tablecolumns[color;tree;text,width=10;text]",
			-- "tableoptions[background=#00000000;border=false]",
			"table[0,0;4.8,6;list_settings;"
		}

		local list = build_list(areas.areas)
		if not self.selected then
			self.selected = 1
		elseif self.selected > #list then
			self.selected = #list
		end

		for i=1, #list do
			local area = list[i]
			print(dump(area))

			if i > 1 then
				fs[#fs + 1] = ","
			end

			local lnd = land.get_by_area_id(area.id)
			local p_lnd = area.parent and land.get_by_area_id(area.parent)

			if lnd then
				fs[#fs + 1] = "#69f,"
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
			local area = list[self.selected]

			if land.get_by_area_id(area.id) then
				fs[#fs + 1] = "button[0.1,6.2;2,1;unzone;Unzone]"
			else
				fs[#fs + 1] = "button[0,6.2;1.25,1;to_zone;To Zone]"
				fs[#fs + 1] = "button[1.25,6.2;1.25,1;transfer;Transfer]"
				fs[#fs + 1] = "button[2.5,6.2;1.25,1;delete;Delete]"
				fs[#fs + 1] = "button[3.75,6.2;1.25,1;;]"
			end

		else
			fs[#fs + 1] = "label[0.1,6.1;No area selected]"
		end

		return table.concat(fs, "")
	end,
	function(self, player, formname, fields)
		if fields.to_zone and self.selected then
			local suc, msg = land.create_zone(self.selected, "commercial")
			self.selected = self.selected + 1
			if msg then
				minetest.chat_send_player(player:get_player_name(), msg)
			end
			return true
		end
	end)
