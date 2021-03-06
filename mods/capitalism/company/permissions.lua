---
-- @module company

--- Permissions table
company.permissions = {
	SWITCH_TO      = "Can act on behalf of the company - needed to do anything else",
	EDIT_DETAILS   = "Can edit the company's details, including name and branding",
	TRANSFER_MONEY = "Can transfer money to another company or individual",
	TRANSFER_LAND  = "Can transfer land to another company or individual, without payment",
	SELL_LAND      = "Can put land up for sale",
	BUY_LAND       = "Can buy land. Requires TRANSFER_MONEY",
	INTERACT_AREA  = "Can build/dig/etc on company land",
	CHANGE_SPAWN   = "Can change the spawn position of a plot.",
	OWNS_AREA      = "Can perform general area admin actions",
	SHOP_CREATE    = "Can create a shop on commercial areas",
	SHOP_ADMIN     = "Can change the settings of a shop, including prices",
	SHOP_CHEST     = "Can place, modify shop chests",
	BUY_ITEMS      = "Can buy from shops",
	MANAGE_MEMBERS = "Can manage company members",
}
