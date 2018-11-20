banking._accounts = {}
banking._account_by_owner = {}

local adt = audit("banking")

function banking.get_balance(comp)
	local acc = banking.get_by_company(comp)
	assert(acc)
	return acc.balance
end

function banking.add_account(acc)
	assert(not banking._account_by_owner[acc.owner])

	banking.dirty = true

	banking._accounts[#banking._accounts + 1] = acc
	banking._account_by_owner[acc.owner]      = acc
	return acc
end

function banking.get_by_owner(owner)
	return banking._account_by_owner[owner]
end

function banking.get_by_company(cname)
	if type(cname) == "table" then
		cname = cname.name
	end

	return banking.get_by_owner("c:" .. cname)
end

function banking.transfer(actor, from, to, amount, reason)
	assert(type(actor)  == "string")
	assert(type(from)   == "string")
	assert(type(to)     == "string")
	assert(type(amount) == "number")
	assert(reason == nil or type(reason) == "string")

	local from_acc = banking.get_by_owner(from)
	assert(from_acc)

	local to_acc   = banking.get_by_owner(to)
	assert(to_acc)

	local from_company = company.get_from_owner_str(from_acc.owner)
	local meta = { from = from, to = to, amount = amount }

	if from_company and
			not company.check_perm(actor, from_company.name, "TRANSFER_MONEY", meta) then
		return false, "Missing permission: TRANSFER_MONEY"
	end

	if not from_acc:withdraw(amount, to_acc, reason) then
		return false, "Insufficient funds"
	end

	to_acc:deposit(amount, from_acc, reason)

	banking.dirty = true

	adt:post(actor, from_company and from_company.name,
		"Transfers " .. amount .. " to " .. to_acc.owner)
	return true
end


company.register_on_create(function(comp)
	local acc = banking.Account:new()
	acc.owner = "c:" .. comp.name
	banking.add_account(acc)
end)


local storage = minetest.get_mod_storage()
lib_utils.make_saveload(banking, storage, "_accounts", "add_account", banking.Account)
banking.load()

for _, comp in pairs(company._companies) do
	if not banking.get_by_company(comp) then
		local acc = banking.Account:new()
		acc.owner = "c:" .. comp.name
		banking.add_account(acc)
	end
end
