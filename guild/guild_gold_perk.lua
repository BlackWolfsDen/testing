if(player:IsInGuild()) then
--	TrinityCore rev. 0a1652d5a608+ 2014-03-13 20:46:21 +0200 (master branch) (Win32, Release) (worldserver-daemon)
--	player:DepositBankMoney(gold*0.1)-- (DepositBankMoney)nil value
    local data = CreatePacket(0x03EC, (1+8+1+8)) -- 0x03EC
    data:WriteUByte(0);
    data:WriteGUID(12496);-- GUID of guild vault in orgrimmar testing using horde toon while close to guild vault.
    data:WriteUByte(0);
    data:WriteGUID(gold*0.1);-- 10% of looted gold.
    player:GetGuildId():SendPacket(data);
	player:SendBroadcastMessage("You loot "..Money.Gold..Money.SilverComma..Money.Silver..Money.CopperComma..Money.Copper..". ("..(math.floor(gold*convert)/10^0)..currency.." deposited to guild bank)")
else
	plr:SendBroadcastMessage("You loot "..Money.Gold..Money.SilverComma..Money.Silver..Money.CopperComma..Money.Copper.."")
