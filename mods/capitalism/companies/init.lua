companies = {}

-- Get companies a player can operate as
--
-- @param name player name
-- @return list of company names
function companies.get_player_companies(name)
	-- TODO: dummy
	return {"corp1"}
end

-- The current company the player is operating as
--
-- @param name player name
-- @return company name
function companies.get_current_company(name)
	-- TODO: dummy
	return companies.get_player_companies(name)[1]
end

-- Tells the player to select a company to operate as (or make one first)
--
-- @param name player name
-- @return nil
function companies.show_select_company_message(name)
	local comps = companies.get_player_companies(name)
	if #comps > 0 then
		minetest.chat_send_player(name, "You need to select a company to operate as first!")
	else
		minetest.chat_send_player(name, "You need to create or join a company first!")
	end
end
