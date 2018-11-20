local adt = audit("company.cmd")

ChatCmdBuilder.new("company", function(cmd)
	cmd:sub("list", function(name)
		if #company._companies == 0 then
			return true, "No companies registered."
		else
			return true, table.concat(_.map(company._companies, function(comp)
				return " - " .. comp.title .. " by " .. comp:get_ceo_name()
			end), "\n")
		end
	end)

	cmd:sub("register :title:text", function(name, title)
		local comp = company.Company:new()
		comp:set_title_calc_name(title)
		comp.owner = name

		if #title < 3 then
			return false, "Company names must be at least 3 characters"
		end

		local existing = company.get_by_name(comp.name)
		if existing then
			return false,
				"Please choose a unique name, that was too similar to " .. existing.name
		end

		if company.create(comp) then
			adt:post(name, comp.name, "Registered company")
			company.save()
			return true, "Registered company"
		else
			return false, "Unable to register company, an unknown error occured"
		end
	end)

	cmd:sub("show :cname", function(name, cname)
		local comp = company.get_by_name(cname)
		if not comp then
			return false, "No company by the name '" .. cname  .. "' found"
		end

		local msg = ""
		for key, value in pairs(comp:to_table()) do
			if type(value) == "string" or type(value) == "number" then
				msg = msg .. minetest.colorize("#bbb", key .. ": ") .. value .. "\n"
			end
		end
		return true, msg
	end)

	cmd:sub("use :cname", function(name, cname)
		if company.set_active(name, cname) then
			return true, "You are now operating as " .. cname
		else
			return false, "No company by the name '" .. cname  .. "' found"
		end
	end)
end, {
	description = "Company tools"
})
