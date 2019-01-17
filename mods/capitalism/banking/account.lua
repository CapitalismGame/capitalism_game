--- Introduces bank accounts and transactions.
-- @module banking

--- Account
--
-- Class which represents a bank account
-- @type Account
local Account = {}
banking.Account = Account


--- Constructor
--
-- @param obj A table to construct an object on top of
-- @treturn banking.Account
function Account:new(obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	self.owner   = nil
	self.balance = 0
	self.ledger  = {}
	return obj
end


--- Export to Lua table
--
-- @treturn table
function Account:to_table()
	return {
		owner   = self.owner,
		balance = self.balance,
		ledger  = self.ledger
	}
end


--- Import from Lua table
--
-- @tparam table t
-- @treturn bool true for success
function Account:from_table(t)
	self.owner   = t.owner
	self.balance = t.balance
	self.ledger  = t.ledger

	return type(self.owner) == "string" and
		type(self.balance) == "number" and
		type(self.ledger) == "table"
end


--- Withdraw from account
--
-- @int amount
-- @string to target account
-- @string reason Transaction message
-- @treturn bool Returns false on failure
function Account:withdraw(amount, to, reason)
	assert(amount > 0)

	if amount > self.balance then
		return false
	end

	self.balance = self.balance - amount
	return true
end


--- Deposit into account
--
-- @int amount
-- @string from from account
-- @string reason Transaction message
function Account:deposit(amount, from, reason)
	assert(amount > 0)

	self.balance = self.balance + amount
end
