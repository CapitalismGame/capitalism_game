local Account = {}
banking.Account = Account

function Account:new(obj)
	obj = obj or {}
	setmetatable(obj, self)
	self.__index = self
	self.owner   = nil
	self.balance = 0
	self.ledger  = {}
	return obj
end

function Account:to_table()
	return {
		owner   = self.owner,
		balance = self.balance,
		ledger  = self.ledger
	}
end

function Account:from_table(t)
	self.owner   = t.owner
	self.balance = t.balance
	self.ledger  = t.ledger

	return type(self.owner) == "string" and
		type(self.balance) == "number" and
		type(self.ledger) == "table"
end

function Account:withdraw(amount, to, reason)
	assert(amount > 0)

	if amount > self.balance then
		return false
	end

	self.balance = self.balance - amount
	return true
end

function Account:deposit(amount, to, reason)
	assert(amount > 0)

	self.balance = self.balance + amount
end
