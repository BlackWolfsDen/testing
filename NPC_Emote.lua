NPCEMOTE = {};
local NPCEMOTEIDS = {};

local NPCEMOTEIDS = {
			[1] = {100},
			[2] = {105},
			[3] = {},
			[4] = {}
					};
local Emotemax = 99
				
local function NPC_EMOTE(event, creature, player, emoteid)

	if(emoteid==NPCEMOTE[creature].reactor)then
		if(NPCEMOTE[creature].reaction < Emotemax+1)then
			creature:Emote(NPCEMOTE[creature].reaction)
		else
			creature:AttackStart(player)
		end
	end
end

for ids = 1, #NPCEMOTEIDS do
	local Reactor = math.random(1, Emotemax)
	local Reaction = math.random(1, Emotemax+1)
	NPCEMOTE[ids] = {
	reactor = Reactor,
	reaction = Reaction
					};
					
	for _, v in ipairs(NPCEMOTEIDS[ids]) do
		RegisterCreatureEvent(v, 8, NPC_EMOTE)
	end
end
