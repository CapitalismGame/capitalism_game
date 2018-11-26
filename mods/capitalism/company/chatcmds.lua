local adt = audit("company.cmd")

ChatCmdBuilder.types.comp  = "(c:[a-z]+)"
ChatCmdBuilder.types.owner = "(c?:?[a-z]+)"

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
		comp.ceo = name

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
			return true, "Registered company"
		else
			return false, "Unable to register company, an unknown error occured"
		end
	end)

	cmd:sub("show :cname:comp", function(name, cname)
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

	cmd:sub("use :cname:comp", function(name, cname)
		if company.set_active(name, cname) then
			return true, "You are now operating as " .. cname
		else
			return false, "No company by the name '" .. cname  .. "' found"
		end
	end)

	cmd:sub("member :username:username", function(name, username)
		local comp = company.get_active(name)
		if not comp then
			return false, "Select a company by doing  /company use <NAME>"
		end

		if comp:get_ceo_name() == username then
			return false, username .. " is the CEO of " .. comp.title
		end

		if not minetest.player_exists(username) then
			return false, username .. " doesn't exist"
		end

		local member = comp.members[username]
		if not member then
			return false, username .. " is not a member of " .. comp.title
		end

		local perms = {}
		for key, value in pairs(member.perms) do
			if value then
				perms[#perms + 1] = key
			end
		end

		return true, username .. " is a member of " .. comp.title ..
				"\nPermissions: " .. table.concat(perms, ", ")
	end)

	cmd:sub("add :username:username", function(name, username)
		local comp = company.get_active(name)
		if not comp then
			return false, "Select a company by doing  /company use <NAME>"
		end

		if not comp:check_perm(name, "MANAGE_MEMBERS",
				{ action = "add", name = "username" }) then
			return false, "Missing permission: MANAGE_MEMBERS"
		end

		if comp:get_ceo_name() == username then
			return false, username .. " is the CEO of " .. comp.title
		end

		if comp.members[username] then
			return false, username .. " is already a member of " .. comp.title
		end

		if not minetest.player_exists(username) then
			return false, username .. " doesn't exist"
		end

		local member = comp:add_member(username)
		company.dirty = true

		local perms = {}
		for key, value in pairs(member.perms) do
			if value then
				perms[#perms + 1] = key
			end
		end

		return true, "Added " .. username .. " to " .. comp.title ..
				"\nPermissions: " .. table.concat(perms, ", ")
	end)

	cmd:sub("grant :username:username :permission:alpha", function(name, username, permission)
		local comp = company.get_active(name)
		if not comp then
			return false, "Select a company by doing  /company use <NAME>"
		end

		return company.set_perms(comp, name, username, permission:upper(), true)
	end)

	cmd:sub("revoke :username:username :permission:alpha", function(name, username, permission)
		local comp = company.get_active(name)
		if not comp then
			return false, "Select a company by doing  /company use <NAME>"
		end

		return company.set_perms(comp, name, username, permission:upper(), false)
	end)

	cmd:sub("perms", function(name)
		local comp = company.get_active(name)

		local msg = ""
		for key, value in pairs(company.permissions) do
			local color
			if not comp then
				color = "#bef"
			elseif comp:check_perm(name, key) then
				color = "#bfb"
			else
				color = "#fbb"
			end

			msg = msg .. minetest.colorize(color, key .. ": ") .. value .. "\n"
		end
		return true, msg
	end)

end, {
	description = "Company tools"
})
