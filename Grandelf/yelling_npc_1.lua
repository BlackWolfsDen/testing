local npcList = {3100, 3101, 3102}; 
local range = 40; -- Range that will trigger / stop the npc from announcing.
local delay = 1*10*1000; -- Delay between the announcements.
local subDelay = 1*2*1000; -- Time between linked announcements.

-- {Statement, stated, linked, emote, spellid,{spawn type, spawn id},},
-- statement :: in quotes "blah blah" 
-- stated :: say = 0 // yell = 1 
-- linked :: table key id if your using multiple statements  for one announcement i.e.(yell THEN say)
-- emote :: talk = 1 // yell = 5// Question = 6 // Dance = 10 // Rude = 14 // shout = 22 // 
-- spellid :: spell id
-- http://collab.kpsn.org/display/tc/Emote
-- spawn type :: 0 none, 1 npc // 2 gob
-- spawn id :: id of what to spawn

local annTable = { ["Says"] = {
	[1] = {"Yo, I heard you liked boars!", 1, 0, 6, 58837}, -- Announce with spell cast: 58837.
	[2] = {"What's up dawg?", 0, 100, 1, 0}, -- Announcement say, linked to 100.
	[100] = {"Yo, you good dawg", 0, 101, 1, 0}, -- Announcement say, linked to 101 and linked from 2.
	[101] = {"Hey, I am talking to you!", 1, 0, 1, 0}, -- Announcement yell, linked from 100.
}};

-- Amount values we need in a single table
local reqData = 5; -- {msg, msgType, linkId, emoteId, spellId} = 5.

local function announce(id, pUnit)
	local sayTable = annTable["Says"][id];
	-- Are we missing data? We don't want any nil values ...
	if #sayTable ~= reqData then
		return;
	end
	-- Putting the data from the table into local variables,
	-- to prevent a lot of table indexing.
	local msg, msgType, linkId, emoteId, spellId --[[, spawnType, spawnId]] = table.unpack(sayTable);
	-- Checking the data for events that should occur, if so
	-- let it happen.
	if msgType == 0 then pUnit:SendUnitSay(msg, 0); else pUnit:SendUnitYell(msg, 0); end
	if emoteId ~= 0 then pUnit:Emote(emoteId); end
	if linkId ~= 0 then
		-- Does the table exist?
		if annTable["Says"][linkId] == nil then
			return;
		end
		-- Recursive call to announce, we want the same result right?
		CreateLuaEvent(function() announce(linkId, pUnit); end, subDelay, 1);
	end
	if spellId ~= 0 then pUnit:CastSpell(pUnit, spellId); end
end
	
local function timedSay(_, _, _, pUnit)
	announce(math.random(#annTable["Says"]), pUnit);
end

local function stopAnnounce(pUnit)
	if #pUnit:GetPlayersInRange(range) == 0 then
		annTable[pUnit:GetGUIDLow()] = false;
		return pUnit:RemoveEvents();
	end
	CreateLuaEvent(function() return stopAnnounce(pUnit); end, delay, 1);
end

local function onMotion(_, pUnit, plr)
	-- If we stop announcing if there are no players
	-- in a certain range, we shouldn't start either.
	if #pUnit:GetPlayersInRange(range) == 0 then
		return;
	end
	
	local lGuid = pUnit:GetGUIDLow();
	local unitTable = annTable[lGuid];
	-- Are we announcing?
	if unitTable == nil or unitTable == false then
		annTable[lGuid] = true; -- We are now ...
		pUnit:RegisterEvent(timedSay, delay, 0);
		-- Registering the check to see if we should continue 
		-- to announce or not.
		CreateLuaEvent(function() return stopAnnounce(pUnit); end, delay-1, 1);
	end	
end	
		
for index=1, #npcList do
	RegisterCreatureEvent(npcList[index], 27, onMotion);
end

math.randomseed(os.time());
