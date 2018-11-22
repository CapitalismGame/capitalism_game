lib_quickfs = {}

function lib_quickfs.register(name, func, cb, privs)
	local player_contexts = {}

	minetest.register_on_player_receive_fields(function(player, formname, fields)
		if formname ~= name then
			return
		end

		if privs and not minetest.check_player_privs(player, privs) then
			return
		end

		local playername = player:get_player_name()
		local context = player_contexts[playername]

		if context and cb(context, player, formname, fields) then
			local formspec = func(context, playername)
			minetest.show_formspec(playername, name, formspec)
		end
	end)

	return function(playername, ...)
		if privs and not minetest.check_player_privs(playername, privs) then
			return
		end

		assert(playername, "Player name is nil!")

		local context =  {
			playername = playername,
			args = { ... },
		}
		player_contexts[playername] = context
		local formspec = func(context, playername, ...)
		minetest.show_formspec(playername, name, formspec)
	end
end
