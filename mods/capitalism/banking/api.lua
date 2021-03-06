---
-- @module banking

banking._accounts = {}
banking._account_by_owner = {}

local adt = audit("banking")


--- Gets the balance for a particular account
--
-- @string owner Account owner
-- @treturn int
function banking.get_balance(owner)
	if type(owner) == "table" then
		owner = owner.name
	end
	assert(type(owner) == "string")

	local acc = banking.get_by_owner(owner)
	assert(acc)
	return acc.balance
end


--- Adds an account to the local cache
-- @account acc
function banking.add_account(acc)
	assert(not banking._account_by_owner[acc.owner])

	banking.dirty = true

	banking._accounts[#banking._accounts + 1] = acc
	banking._account_by_owner[acc.owner]      = acc
	return acc
end


--- Gets account by owner name
--
-- @owner owner
-- @treturn banking.Account
function banking.get_by_owner(owner)
	assert(type(owner) == "string")

	return banking._account_by_owner[owner]
end


--- Transfers money between accounts, with permission checking
--
-- @string actor User requesting this transfer
-- @string from From account
-- @string to Target account
-- @int amount
-- @string reason Transaction reason
-- @treturn true
-- @error Error message
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

	local from_company = company.get_by_name(from_acc.owner)
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
	assert(comp.name:sub(1, 2) == "c:")
	acc.owner = comp.name
	acc.balance = 10000
	banking.add_account(acc)
end)
