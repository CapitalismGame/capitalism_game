# Lib QuickFS

```lua
mymod.show_form_to = lib_quickfs.register("mymod:form", {
	-- Callback to check for permissions
	check = function(context, player, ...)
		return true
	end,

	--QuickFS can automatically make or wrap a check method with priv checks
	privs = { kick = true },

	-- Build the FS
	get = function(context, pname, ...)
		return "size[1,1]button[1,1;1,1;a;OK]"
	end,

	-- Handle event, return true to re-send the formspec
	on_receive_fields = function(context, player, fields, ...)

	end
})
```
