minetest.register_on_joinplayer(function(player)
	player:set_formspec_prepend([[
			bgcolor[#080808BB;true]
			background[5,5;1,1;theme_formbg.png;true;10]
			listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]
			style_type[button;bgimg=theme_button.png;bgimg_pressed=theme_button_pressed.png] ]])
end)
