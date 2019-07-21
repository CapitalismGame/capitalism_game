unused_args = false
allow_defined_top = true

exclude_files = {
    "mods/mtg",
    "mods/libs/lib_chatcmdbuilder",
    "mods/libs/lib_utils/vector.lua",
    "mods/mechanics",
    "mods/areas",
    "mods/craftguide",
}

globals = {
    "minetest", "company",
    "areas", "sfinv",
    "shop",
    ChatCmdBuilder = {fields = {"types"}},
    vector = { fields = {"sqdist"}},
}

read_globals = {
    string = {fields = {"split"}},
    table = {fields = {"copy", "getn"}},
	assert = {fields = {"equals", "is_nil", "is_true", "is_false", "is_not_nil", "not_equals", "errors"}},

    -- Builtin
    "vector", "ItemStack",
    "dump", "DIR_DELIM", "VoxelArea", "Settings",

    -- MTG
    "default", "sfinv", "creative", "bucket",

	-- Libs
	"ChatCmdBuilder", "describe", "it", "awards", "node_io",

    "_", "lib_utils", "lib_quickfs",
}
