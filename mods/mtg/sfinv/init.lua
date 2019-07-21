dofile(minetest.get_modpath("sfinv") .. "/api.lua")

sfinv.register_page("sfinv:crafting", {
	title = "Crafting",
	get = function(self, player, context)
		return sfinv.make_formspec(player, context, [[
				real_coordinates[true]
				list[current_player;craft;2.3,0.375;3,3;]
				list[current_player;craftpreview;7.5,1.675;1,1;]
				image[6.2,1.675;1,1;gui_furnace_arrow_bg.png^[transformR270]
				listring[current_player;main]
				listring[current_player;craft]
			]], true)
	end
})
