local npcList = {3100, 3101, 3102}; 
local range = 40; -- Range that will trigger / stop the npc from announcing.
local delay = 1*10*1000; -- Delay between the announcements.
local subDelay = 1*2*1000; -- Time between linked announcements.

local annTable = { ["Says"] = {
	-- [index] = {msg, msgType, linkId, emoteId, spellId},
	[1] = {"Yo, I heard you liked boars!", 1, 0, 6, 58837}, -- Announce with spell cast: 58837.
	[2] = {"What's up dawg?", 0, 100, 1, 0}, -- Announcement say, linked to 100.
	[100] = {"Yo, you good dawg", 0, 101, 1, 0}, -- Announcement say, linked to 101 and linked from 2.
	[101] = {"Hey, I am talking to you!", 1, 0, 1, 0}, -- Announcement yell, linked from 100.
}};

local getCreature = {
	__newindex = function(tbl, key, value)	
		local guid = key:GetGUID();
		if value == false then
			tbl.__cache[guid] = nil; return;
		end
		
		local map = GetMapById(key:GetMapId(), 0);
		-- Set the table, so we know the announcer
		-- started announcing.
		tbl.__cache[guid] = map;
	end,	
	__call = function(tbl, ...)
		local guid = select(1, ...);
		-- Does the table exist already?
		if tbl.__cache[guid] == nil then
			return nil;
		end
		local map = tbl.__cache[guid];
		-- Return the object because that's the value
		-- we want.
		return map:GetWorldObject(guid);
	end,
	__cache = {},
}
setmetatable(getCreature, getCreature);
		
-- Amount values we need in a single table
local reqData = 5; -- {msg, msgType, linkId, emoteId, spellId} = 5.

local function announce(id, guid)
	local pUnit = getCreature(guid);
	-- If the unit isn't active, we don't want to run this function.
	if type(pUnit) ~= "userdata" then
		return;
	end
	
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
		CreateLuaEvent(function() announce(linkId, pUnit:GetGUID()); end, subDelay, 1);
	end
	if spellId ~= 0 then pUnit:CastSpell(pUnit, spellId); end
end

-- No need to check for active unit here, because this won't
-- be called if the unit isn't active.	
local function timedSay(_, _, _, pUnit)
	announce(math.random(#annTable["Says"]), pUnit:GetGUID());
end

local function onMotion(_, pUnit, plr)
	-- If we stop announcing if there are no players
	-- in a certain range, we shouldn't start either.
	if #pUnit:GetPlayersInRange(range) == 0 then
		return;
	end
	-- Are we announcing?
	if type(getCreature(pUnit:GetGUID())) ~= "userdata" then
		getCreature[pUnit] = true; -- We are now ...
		pUnit:RegisterEvent(timedSay, delay, 0);
	end	
end	

local function cleanTable()
	-- Are there any creatures in the table?
	local cacheTable = getCreature.__cache
	if next(cacheTable) == nil then
		return;
	end
	-- Lets check for creatures that aren't active
	-- and clean the table if that's the case.
	for key, v in pairs(cacheTable) do
		-- Is unit active?
		local pUnit = getCreature(key);
		if type(pUnit) ~= "userdata" then
			getCreature[pUnit] = false;
		elseif #pUnit:GetPlayersInRange(range) == 0 then
			getCreature[pUnit] = false;
		end
	end
end
CreateLuaEvent(cleanTable, 5000, 0);
	
		
for index=1, #npcList do
	RegisterCreatureEvent(npcList[index], 27, onMotion);
end

math.randomseed(os.time());
