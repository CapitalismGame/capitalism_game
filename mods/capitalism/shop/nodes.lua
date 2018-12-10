
minetest.register_node("shop:counter", {
	description = "Counter",

	tiles = { "shop_counter.png" },

	on_rightclick = function(pos, node, player)
		shop.show_shop_form(player:get_player_name(), pos)
	end,

	after_place_node = function(pos, player)
		local pname    = player:get_player_name()
		local suc, msg = shop.create_shop(pname, pos)
		if suc then
			shop.show_shop_form(pname, pos)
		else
			minetest.chat_send_player(pname, msg)
			minetest.remove_node(pos)
			return true
		end
	end,
})

local function can_interact_with_chest(player, pos)
	local area = land.get_by_pos(pos)
	return area and company.check_perm(player:get_player_name(), area.owner,
			"SHOP_CHEST", { area = area })
end

local function can_add_item_to_chest(player, pos, stack)
	if not can_interact_with_chest(player, pos) then
		return false
	end

	local s     = shop.get_by_pos(pos)
	local chest = s:get_chest(pos)
	return not chest.itemname or chest.itemname == stack:get_name()
end

local chest_template
chest_template = {
	description = "Shop Chest",
	sounds = default.node_sound_wood_defaults(),
	groups = {choppy = 2, oddly_breakable_by_hand = 2},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Locked Chest")
		meta:set_string("owner", "")

		local inv = meta:get_inventory()
		inv:set_size("main", 8*2)
	end,
	after_place_node = function(pos, player)
		local pname = player:get_player_name()
		if not can_interact_with_chest(player, pos) then
			minetest.chat_send_player(pname,
				"You don't have permission to do that! (Are you acting as the right company?)")
			minetest.set_node(pos, { name = "air" })
			return false
		end

		local s = shop.get_by_pos(pos)
		if not s then
			minetest.chat_send_player(pname, "Please place a till node first")
			minetest.set_node(pos, { name = "air" })
			return false
		end

		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Shop chest (" .. s.name .. ")")

		s:add_chest(pos)
		shop.dirty = true
	end,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		return inv:is_empty("main") and
				can_interact_with_chest(player, pos)
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index,
			to_list, to_index, count, player)
		return can_interact_with_chest(player, pos) and count or 0
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		return can_add_item_to_chest(player, pos, stack) and stack:get_count() or 0
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		return can_interact_with_chest(player, pos) and stack:get_count() or 0
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local s = shop.get_by_pos(pos)
		s:chest_add_item(pos, stack)
		shop.dirty = true

		-- HACK: player must have the inventory open
		shop.show_chest_form(player:get_player_name(), s, pos)
	end,
	on_metadata_inventory_take = function(pos, listname, index, stack, player)
		local s = shop.get_by_pos(pos)
		s:chest_remove_item(pos, stack)
		shop.dirty = true
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local pname = clicker:get_player_name()
		if not can_interact_with_chest(clicker, pos) then
			minetest.chat_send_player(pname,
					"You don't have permission to do that!\n" ..
					"Go to the counter/till to purchase items")
			return itemstack
		end

		local s = shop.get_by_pos(pos)
		if not s then
			minetest.chat_send_player(pname, "Unable to find a shop")
			minetest.set_node(pos, { name = "air" })
			return false
		end

		shop.show_chest_form(pname, s, pos)
		return itemstack
	end,
}

minetest.register_node("shop:chest", _.extend(chest_template, {
	tiles = {
		"shop_chest_top.png",
		"shop_chest_top.png",
		"shop_chest_side.png",
		"shop_chest_side.png",
		"shop_chest_front.png",
		"shop_chest_side.png"
	},
}))


minetest.register_craft({
	output = "shop:counter",
	recipe = {
		{"oil:plastic_sheet", "default:glass", "oil:plastic_sheet"},
		{"default:stick",     "chips:chip",    "default:stick"    },
		{"default:stick",     "",              "default:stick"    },
	},
})

minetest.register_craft({
	output = "shop:chest",
	recipe = {
		{"default:wood", "default:wood",      "default:wood"},
		{"default:wood", "oil:plastic_sheet", "default:wood"},
		{"default:wood", "default:wood",      "default:wood"},
	},
})

minetest.register_craft({
	output = "shop:chest",
	type   = "shapeless",
	recipe = { "default:chest", "oil:plastic_sheet"},
})
