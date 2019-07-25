function gametime.get()
	local days = minetest.get_day_count()
	local years = math.floor(days / 360)
	days = days - years * 360
	local months = math.floor(days / 12)
	days = days - months * 12
	assert(days < 30)

	return {
		year = years + 1900,
		month = months + 1,
		day = days + 1,
	}
end

local MONTH_NAMES = {
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December",
}

function gametime.get_formatted()
	local date = gametime.get()
	local month_name = MONTH_NAMES[date.month]
	return ("%02d-%s-%04d"):format(date.day, month_name, date.year)
end

local _registered_on_day_change = {}
local _registered_on_month_change = {}
local _registered_on_year_change = {}

function gametime.register_on_day_change(func)
	table.insert(_registered_on_day_change, func)
end

function gametime.register_on_month_change(func)
	table.insert(_registered_on_month_change, func)
end
function gametime.register_on_year_change(func)
	table.insert(_registered_on_year_change, func)
end

local _lastcount = minetest.get_day_count()

local function on_interval()
	local cur = minetest.get_day_count()
	if _lastcount == cur then
		return
	end

	_lastcount = cur

	local curdate = gametime.get()
	for i=1, #_registered_on_day_change do
		_registered_on_day_change[i](cur, curdate)
	end

	if curdate.day == 1 then
		for i=1, #_registered_on_month_change do
			_registered_on_month_change[i](cur, curdate)
		end

		if curdate.month == 1 then
			for i=1, #_registered_on_year_change do
				_registered_on_year_change[i](cur, curdate)
			end
		end
	end
end

lib_utils.interval(2, on_interval)
