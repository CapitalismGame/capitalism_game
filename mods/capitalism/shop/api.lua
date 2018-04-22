_.extend(shop, {
	_shops = {},
	_shops_by_name = {},
	_context = {}
})

function shop.get_by_name(name)
	return name and shop._shops_by_name[name:lower()]
end

function shop.register_shop(name, def)
	name = name:lower()
	if shop._shops[name] then
		return false
	end

	def.name = name
	shop._shops[#shop._shops + 1] = def
	shop._shops_by_name[name] = def
	return true
end

function shop.init_inventory(name)
	return minetest.create_detached_inventory("shop_inv_" .. name, {
		allow_put = function(inv, listname, index, stack, player)
			return 0
		end,

		allow_take = function(inv, listname, index, stack, player)
			return 0
		end
	})
end

function shop.get_inventory_or_create(name)
	return minetest.get_inventory({
		type = "detached",
		name = "shop_inv_" .. name
	}) or shop.init_inventory(name)
end

function shop.show_shop_form(player, pos)
	local playername = player:get_player_name()

	local meta = minetest.get_meta(pos)
	local shop_name = meta:get_string("shop_name")
	if shop_name == "" then
		shop.show_shop_config_form(playername, pos, meta)
	else
		shop.show_shop_checkout_form(playername, pos, meta)
	end
end

local function getListnameFromPos(pos)
	local x = pos.x
	local y = pos.y
	local z = pos.y
	if x < 0 then
		x = "n" .. -x
	end
	if y < 0 then
		y = "n" .. -y
	end
	if z < 0 then
		z = "n" .. -z
	end
	return x .. "_" .. y .. "_" .. z
end

shop.show_shop_checkout_form = lib_quickfs.register("shop:counter", function(self, playername, pos, meta)
		local owner_company = meta:get_string("owner_company")
		local comp = company.get_active_company(playername)
		self.pos = pos
		self.is_admin = comp and comp.name == owner_company or false


		local shop_name = meta:get_string("shop_name")
		local inv = shop.get_inventory_or_create(shop_name)
		local listname = getListnameFromPos(pos)
		inv:set_list(listname, {})
		inv:add_item(listname, ItemStack("default:dirt 99"))
		inv:add_item(listname, ItemStack("default:stone 99"))
		inv:add_item(listname, ItemStack("default:mese 99"))

		return "size[10,6]list[detached:shop_inv_" .. shop_name .. ";" .. listname .. ";8,0;2,6]"
	end,
	function(self, player, formname, fields)

	end)


shop.show_shop_config_form = lib_quickfs.register("shop:counter_setup", function(self, playername, pos, meta)
		local owner_company = meta:get_string("owner_company")
		local comp = company.get_active_company(playername)
		if comp and comp.name == owner_company then
			self.pos = pos
			return [[
					size[5,3]
					label[0,0;Please connect this counter to a shop]
					field[0.5,1.3;4,1;shop_name;Shop Name;]
					button_exit[1,2;2,1;save;Connect]
				]]
		else
			return "size[5,2]label[0,0;" ..
					minetest.formspec_escape("You don't have the rights to " .. owner_company) ..
					"]button_exit[1,1;2,1;close;exit]"
		end
	end,
	function(self, player, formname, fields)
		local playername = player:get_player_name()
		if fields.save and self.pos then
			local meta = minetest.get_meta(self.pos)

			-- Get Shop by name, and connect if it exists
			local shop_name = fields.shop_name
			local obj = shop.get_by_name(shop_name)
			if obj then
				meta:set_string("shop_name", obj.name)
				minetest.chat_send_player(playername, "Connected counter to shop " .. obj.name)
			else
				minetest.chat_send_player(playername, "No such shop " .. shop_name)
			end

			-- Show form again
			shop.show_shop_form(player, self.pos)
		end
	end)

local storage = minetest.get_mod_storage()
lib_utils.make_saveload(shop, storage, "_shops", "register_shop", shop.Shop)

shop.load()
