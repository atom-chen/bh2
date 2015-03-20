local LootMgr = class("LootMgr")
LootMgr.__index = LootMgr

local __instance = nil
local __allowInstance = nil

function LootMgr:ctor()
    if not __allowInstance then
		error("LootMgr is a singleton")
	end

	self._entries = {}
	--self:Init()
end

function LootMgr:getInstance( )
	if not __instance then
		__allowInstance = true
		__instance = LootMgr.new()
		__allowInstance = false
	end

	return __instance
end

LootMgr._group = {}

function LootMgr:addEntry(entry)
	assert(type(entry) == "table","Invalid type")

	if not self._entries[entry.id] then
		self._entries[entry.id] = {}
	end
	if not self._entries[entry.id][entry.groudId] then
		self._entries[entry.id][entry.groudId] = {}
	end
	local group = self._entries[entry.id][entry.groudId]
	group[#group + 1] = {word = entry.word_id,chance = entry.chance}

	--assert(false)
end

function LootMgr:Loot(lootid,count)
	local groups = self._entries[lootid]
	local retTb = {}
	for k,group in pairs(groups) do
		if #retTb < count then
			retTb[#retTb + 1] = self:Process(group)
		end
	end
	return retTb
end

function LootMgr:Process(group)
	local ret = self:Roll(group)
	assert(ret,"roll nil item")
	return ret
end

function LootMgr:Roll(group)
	math.newrandomseed()
	local roll = math.random(1,100)
	cclog("LootMgr:Roll(),random value is "..roll)
	for i = 1,#group do
		if group[i].chance >= 100 then
			return group[i].word
		end 
		roll = roll - group[i].chance
		if roll < 0 then
			return group[i].word
		end
	end

	return nil
end

return LootMgr