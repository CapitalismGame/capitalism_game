ChatCmdBuilder.new("company", function(cmd)
	cmd:sub("list", function(name)
		if #company._companies == 0 then
			return true, "No companies registered."
		else
			return true, table.concat(_.map(company._companies, function(comp)
				return " - " .. comp.name .. " by " .. comp:get_primary_owner()
			end), "\n")
		end
	end)

	cmd:sub("register :cname", function(name, cname)
		local comp = company.Company:new()
		comp.name = cname
		comp.owner = name

		if #cname < 3 then
			return false, "Company names must be at least 3 characters"
		end

		if cname:match("%W") then
			return false, "Company names can only consist of letters and numbers"
		end

		if company.register_company(cname, comp) then
			company.save()
			return true, "Registered company"
		else
			return false, "Unable to register company, a company of that name already exists"
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
		if company.set_active_company(name, cname) then
			return true, "You are now operating as " .. cname
		else
			return false, "No company by the name '" .. cname  .. "' found"
		end
	end)
end, {
	description = "Company tools"
})
