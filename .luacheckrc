unused_args = false
allow_defined_top = true

exclude_files = {"mods/mtg", "mods/libs/lib_chatcmdbuilder"}

globals = {
    "minetest",
}

read_globals = {
    string = {fields = {"split"}},
    table = {fields = {"copy", "getn"}},
	assert = {fields = {"equals", "is_nil", "is_true", "is_false", "is_not_nil", "not_equals"}},

    -- Builtin
    "vector", "ItemStack",
    "dump", "DIR_DELIM", "VoxelArea", "Settings",

    -- MTG
    "default", "sfinv", "creative",

	-- Libs
	"ChatCmdBuilder", "describe", "it", "awards",
}
