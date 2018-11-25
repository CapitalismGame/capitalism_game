lib_quickfs = {}

function lib_quickfs.register(name, def)
	assert(type(def) == "table")
	assert(type(def.get) == "function")
	assert(type(def.on_receive_fields) == "function")

	local player_contexts = {}

	if def.privs then
		local oldcheck = def.check
		def.check = function(context, player, ...)
			if not minetest.check_player_privs(player, def.privs) then
				return false
			end

			return oldcheck and oldcheck(...) or true
		end
	end

	minetest.register_on_player_receive_fields(function(player, formname, fields)
		if formname ~= name then
			return
		end

		local pname = player:get_player_name()
		local context = player_contexts[pname]

		if def.check and not def.check(context, player, unpack(context.args)) then
			return
		end

		if context and def.on_receive_fields(context, player, fields, unpack(context.args)) then
			def.show(context, player)
		end
	end)

	def.show = function(context, player)
		local formspec = def.get(context, player, unpack(context.args))
		minetest.show_formspec(context.pname, name, formspec)
	end

	return function(pname, ...)
		if def.privs and not minetest.check_player_privs(pname, def.privs) then
			return
		end

		assert(pname, "Player name is nil!")

		local context =  {
			pname = pname,
			args = { ... },
		}

		local player = minetest.get_player_by_name(pname)
		if def.check and not def.check(context, player, ...) then
			return
		end

		player_contexts[pname] = context
		def.show(context, player)
	end
end
