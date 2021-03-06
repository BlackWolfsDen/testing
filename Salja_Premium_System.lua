-- Premium System by Salja of emudevs.com
-- updated by slp13at420 of emudevs.com
-- NOTE: need to insert character_premium.sql in your auth.account database.table
-- just add 1 column to your auth.account table:
-- name `premium` : Datatype = TINYINT : Length/Set = 1 : Unsigned = checked : Default = 0

-- NOT YET FULLY TESTED . just theoretical .
-- Buff me selection working. now everything is working except the vendor selections.
-- for TrintyCore2 3.3.5 Eluna
BUFFS = {};
PREM = {};
local BUFFS = {48074,43223,36880,467,48469,48162,23948,24752,16877,10220,13033,11735,10952};

print ("Salja's Premium System Table: initialized and allocated.")

local function PremiumOnLogin(event, player)  -- Send a welcome massage to player and tell him is premium or not

local Q = WorldDBQuery("SELECT username, premium FROM auth.account WHERE `id` = '"..player:GetAccountId().."';"); -- this would need to be changed for your Premium value location.

PREM[player:GetAccountId()] = {
	Name = Q:GetString(0),
	Premium = Q:GetUInt32(1)
				};
			
	if(PREM[player:GetAccountId()].Premium==1)then
		player:SendBroadcastMessage("|CFFE55BB0[Premium]|r|CFFFE8A0E Welcome "..player:GetName().." you are Premium! |r")
	else
		player:SendBroadcastMessage("|CFFE55BB0[Premium]|r|CFFFE8A0E Welcome "..player:GetName().." you are NOT Premium! |r")
		player:SendBroadcastMessage("|CFFE55BB0[Premium]|r|CFFFE8A0E You can donate to earn the Premium Rank.|r")
    	end
print(PREM[player:GetAccountId()].Name.." :Premium table loaded.")
end

local function PremiumOnChat(event, player, msg, _, lang)
	if (msg == "#premium") then  -- Use #premium for sending the gossip menu
		if(PREM[player:GetAccountId()].Premium==1)then
            OnPremiumHello(event, player)
        else
            player:SendBroadcastMessage("|CFFE55BB0[Premium]|r|CFFFE8A0E Sorry "..player:GetName().." you dont have the Premium rank. |r")
        end
    end
end

function OnPremiumHello(event, player)
	player:GossipClearMenu()
	player:GossipMenuAddItem(0, "Show Bank.", 0, 2)
	player:GossipMenuAddItem(0, "Show AuctionsHouse.", 0, 3)
	player:GossipMenuAddItem(0, "Summon the Premium Vendor.", 0, 4)
	player:GossipMenuAddItem(0, "Buff me.", 0, 5)
	player:GossipMenuAddItem(0, "Repair my items.", 0, 6)
	player:GossipMenuAddItem(0, "Nevermind..", 0, 1)
	player:GossipSendMenu(1, player, 100)
end

function OnPremiumSelect(event, player, unit, sender, intid, code)
	
	if(intid==1) then               -- Close the Gossip
        end
 	if(intid==2) then           -- Send Bank Window
        	player:SendShowBank(player)
        end
	if(intid==3) then           -- Send Auctions Window
        	player:SendAuctionMenu(player)
        end
	if(intid==4)then		-- summon the premium vendor
		AddVendorItem(100,25,1,1,3006)
		player:SendVendorWindow(100)
	end
	if(intid==5)then          -- buff  me
		for _, v in ipairs(BUFFS)do
			player:AddAura(v, player)
		end
	end
	if (intid==6) then		-- Repair all items 100%
		player:DurabilityRepairAll(100,100)
	end
	if(intid > 6) then          -- Go back to main menu
		player:GossipComplete()
		OnPremiumHello(event, player)
	end
    -- Room for more premium things
player:GossipComplete()
end

RegisterPlayerEvent(3, PremiumOnLogin)              -- Register Event On Login
RegisterPlayerEvent(18, PremiumOnChat)              -- Register Evenet on Chat Command use
RegisterPlayerGossipEvent(100, 2, OnPremiumSelect)  -- Register Event for Gossip Select
