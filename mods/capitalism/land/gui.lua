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


land.show_debug_to = lib_quickfs.register("land:debug", function(self, playername, pos, meta)
		local fs = {
			"size[5,6]",
			"tablecolumns[color;tree;text,width=10;text]",
			-- "tableoptions[background=#00000000;border=false]",
			"table[0,0;4.8,6;list_settings;"
		}

		local list = build_list(areas.areas)

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

		fs[#fs + 1] = "]"

		return table.concat(fs, "")
	end,
	function(self, player, formname, fields)

	end)
