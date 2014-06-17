 -- this example will deposit 10% of looted gold,silver,copper into players guild bank
local function OnLootMoney(eventid, player, amount)
local gold = math.floor(amount*0.1)
	if (player:IsInGuild()) then
		player:GetGuild():DepositBankMoney(player, gold)
	end
end

RegisterPlayerEvent(37, OnLootMoney)
