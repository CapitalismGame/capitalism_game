# Developer's Introduction

## Code Structure

* **capitalism** - mods specifically created for this game
* **libs** - libraries, don't add or change anything by default
* **mtg** - unmodified mtg mods
* additional mods:
	* **crafting** - provides new crafting system

## Basic Concepts

A player belongs to zero, one, or more companies.
A player can act on behalf of only one company at
a time - this is their active company. The active company can be obtained using the following function:

```lua
local comp = company.get_active(name)
```

### Actions and Permissions

Actions include:

* Setting up craft networks and factories (`CREATE_FACTORY`, `EDIT_FACTORY`)
* Making deals (`NEGOTIATE_TRADE`)
* Making aquisitions (`NEGOTIATE_STOCK`)

These actions are subject to having the appropriate permission:

```lua
if not comp:check_perm(name, perm_name, meta) then
	error("can't do this!")
end
```

Permissions can be granted by the CEO of a company to other
players at any time. This is done as part of the player tab
in the inventory formspec.

You can see a list of permissions and their meaning in
mods/capitalism/company/permissions.lua

## Data Persistence

There's a helper available to save and load arrays of classes:

```lua
if minetest then
	local storage = minetest.get_mod_storage()
	lib_utils.make_saveload(company, storage, "_companies", "add", company.Company)
	company.load()
end
```

make_saveload parameters:

* **tab** - The mod's table.
* **storage** - ModStorageRef
* **itemarraykey** - Key for the table of object, `tab[itemarraykey]`.
* **regkey** - The add function, `tab[regkey]`.  Returns true on success.
* **class** - a reference to the class. Must have:
	* `:new()` with metatables and initialisation
	* from_table(), returns true if successful
	* to_table(), returns table

## Conventions

### Common Variable Names

* `name` - player name
* `comp` - company
* `cname` - company name
* `pname` - player name
* `area` - an *areas* area
* `acc` - bank account
