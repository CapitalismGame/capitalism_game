cash.register("money:note_10", {
	description = "$10 Note",
	groups = { money = 1000 },
})

cash.register("money:note_5", {
	description = "$5 Note",
	groups = { money = 500 },
})

cash.register("money:coin_2", {
	description = "$2 Coin",
	groups = { money = 200 },
})

cash.register("money:coin_1", {
	description = "$1 Coin",
	groups = { money = 100 },
})

cash.register("money:coin_50", {
	description = "50c Coin",
	groups = { money = 50 },
})

minetest.register_craftitem("money:coin_10", {
	description = "10c Coin",
	groups = { money = 10 },
})

minetest.register_craftitem("money:coin_5", {
	description = "1c Coin",
	groups = { money = 1},
})
