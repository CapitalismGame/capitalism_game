minetest.register_craftitem("chips:silicon", {
	description     = "Silicon",
	inventory_image = "chips_silicon.png",
})

minetest.register_craftitem("chips:wafer", {
	description     = "Silicon Wafer",
	inventory_image = "chips_wafer.png",
})

minetest.register_craftitem("chips:chip", {
	description     = "Chip",
	inventory_image = "chips_chip.png"
})

minetest.register_craft({
	output = "chips:silicon",
	type   = "shapeless",
	recipe = {"default:sand 5"},
})

minetest.register_craft({
	output = "chips:wafer",
	recipe = {
		{"chips:silicon",      "default:gold_ingot", "chips:silicon"     },
		{"default:gold_ingot", "chips:silicon",      "default:gold_ingot"},
		{"chips:silicon",      "default:gold_ingot", "chips:silicon"     },
	}
})

minetest.register_craft({
	output = "chips:chip",
	type   = "shapeless",
	recipe = {"chips:wafer"},
})
