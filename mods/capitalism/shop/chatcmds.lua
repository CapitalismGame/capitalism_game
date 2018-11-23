ChatCmdBuilder.new("shop", function(cmd)
	cmd:sub("list", function(name)
		if #shop._shops == 0 then
			return true, "No shops registered."
		else
			return true, table.concat(_.map(shop._shops, function(shop)
				return " - " .. shop.name .. " by <?>"
			end), "\n")
		end
	end)

	cmd:sub("show :cname", function(name, cname)
		local obj = shop.get_by_name(cname)
		if not obj then
			return false, "No shop by the name '" .. cname  .. "' found"
		end

		local msg = ""
		for key, value in pairs(obj:to_table()) do
			if type(value) == "string" or type(value) == "number" then
				msg = msg .. minetest.colorize("#bbb", key .. ": ") .. value .. "\n"
			end
		end
		return true, msg
	end)
end, {
	description = "Shop tools"
})
