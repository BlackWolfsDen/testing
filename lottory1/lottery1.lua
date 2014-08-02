print("\n-----------------------------------")
print("Grumbo\'z Loco Lotto starting ...\n")
local npcid = 390000
local LottoTimer
local LottoSettings
local LottoEntries = {}

local function GetLotto(guidlow)
    return LottoEntries[guidlow]
end

local function GetOrCreateLotto(guidlow)
    LottoEntries[guidlow] = LottoEntries[guidlow] or {guid = guidlow, count = 0}
    return GetLotto(guidlow)
end

local function LottoSave(lowguid)
    local lotto = GetLotto(lowguid)
    if (lotto and not lotto.saved) then
        CharDBExecute("REPLACE INTO lotto.entries (`guid`, `count`) VALUES ("..lowguid..", "..lotto.count..")")
    end
end

local function LottoDeleteAll()
    LottoEntries = nil
    CharDBExecute("DELETE FROM lotto.entries")
end

local function LottoLoader()
    local LS = CharDBQuery("SELECT * FROM lotto.settings")
    if (LS) then
        LottoSettings = {
            item = LS:GetUInt32(1),
            cost = LS:GetUInt32(2),
            timer = LS:GetUInt32(3),
            operation = LS:GetUInt32(4),
            mumax = LS:GetUInt32(5),
            require = LS:GetUInt32(6)
        };
    else
        error("No settings found for lotto, cant start")
    end

    local LE = CharDBQuery("SELECT `guid`, `count` FROM lotto.entries")
    if (LE) then
        repeat
            LottoEntries[LE:GetUInt32(0)] = {
                guid = LE:GetUInt32(0),
                count = LE:GetUInt32(1),
                saved = true
            };
        until not LE:NextRow()
    end
end

local function Tally(event)
    
    -- Make this a config
    if (#LottoEntries < LottoSettings.require) then
        SendWorldMessage("Not enough Loco Lotto Entries this round.")
        return
    end
    
    local pot = 0
    local entries = {}
    for k,v in pairs(LottoEntries) do
        pot = pot + v.count
        table.insert(entries, k)
    end

    print("tally")

    local winkey = entries[math.random(1, #entries)]
    local winlotto = LottoEntries[winkey]
    local player = GetPlayerByName(winlotto.name)

    if (player) then
        local multiplier = math.random(1, LottoSettings.mumax)
        local bet = winlotto.count*multiplier
        SendWorldMessage("Contgratulations to "..winlotto.name.." our new winner. Total:"..(pot+bet)..". Its LOCO!!")
        player:AddItem(LottoSettings.item, (pot+bet))
        LottoDeleteAll()

    else
        -- Instead of this, could just get a new winner that is online, since atm there sorta is always a winner if all players are online
        -- Or then think of some other logic that this isnt so random
        SendWorldMessage("No Winners this Loco lotto round.")
    end

    if (LottoSettings.operation ~= 1) then
        RemoveEventById(LottoTimer)
        LottoTimer = nil
    end
    
end

local function LottoOnHello(event, player, unit)
    local lotto = GetLotto(player:GetGUIDLow())
    local count = lotto and lotto.count or 0
    player:GossipClearMenu()
    player:GossipMenuAddItem(0, "You have entered "..count.." times", 0, 2)
    player:GossipMenuAddItem(0, "Enter the lotto.", 0, 1)
    player:GossipMenuAddItem(0, "never mind.", 0, 0)
    player:GossipSendMenu(1, unit)
end

local function LottoOnSelect(event, player, unit, sender, intid, code)
    if (intid == 0) then
        player:GossipComplete()
        return
    end

    if (intid == 1) then
        if (player:GetItemCount(LottoSettings.item) == 0) then
            player:SendBroadcastMessage("You Loco .. you dont have enough currency to enter.")
        else
            local guid = player:GetGUIDLow()
            local lotto = GetOrCreateLotto(guid)
            if (lotto) then
                lotto.saved = nil
                lotto.count = lotto.count+1
                player:SendBroadcastMessage("You have entered "..lotto.count.." times.")
 				player:RemoveItem(LottoSettings.item, LottoSettings.cost)
            end
        end
    end
    
    LottoOnHello(1, player, unit)
end

local function OnSave(event, player)
    LottoSave(player:GetGUIDLow())
end

LottoLoader()
RegisterCreatureGossipEvent(npcid, 1, LottoOnHello)
RegisterCreatureGossipEvent(npcid, 2, LottoOnSelect)
RegisterPlayerEvent(25, OnSave)

print("Grumbo'z Loco Lotto Operational.")

if (LottoSettings.operation == 1) then
    LottoTimer = CreateLuaEvent(Tally, LottoSettings.timer, 0)
    print("...Lotto Started...")
else
    print("...System idle...")
end
print("-----------------------------------\n")
