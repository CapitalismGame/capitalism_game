local hud = hudkit()

local function update_datetime(player)
	local date = gametime.get_formatted()
	local tod = minetest.get_timeofday()
	local hours = math.floor(tod * 24)
	local minutes = math.floor(tod * 1440 - hours * 60)
	local datetime = ("%s %02d:%02d"):format(date, hours, minutes)

	if not hud:exists(player, "gametime:datetime") then
		hud:add(player, "gametime:datetime", {
			hud_elem_type = "text",
			position      = {x = 0.5, y = 0},
			scale         = {x = 100, y = 100},
			text          = datetime,
			number        = 0xFFFFFF,
			offset        = {x = 0, y = 20},
			alignment     = {x = 0, y = 0}
		})
	else
		hud:change(player, "gametime:datetime", "text", datetime)
	end
end

minetest.register_on_joinplayer(update_datetime)
lib_utils.interval(1, function()
	local players = minetest.get_connected_players()
	for i=1, #players do
		update_datetime(players[i])
	end
end)
