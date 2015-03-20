local ItemLootMgr = class("ItemLootMgr")

local lootGroup = 
{
	_chances = {},
}

function lootGroup:Roll()
	local roll = rand_chance()
	cclog("lootGroup:Roll(),random value is "..roll)
	for _,entry in pairs(self._chances) do
		if entry.chance >= 100 then
			return entry.item_id
		end
		roll = roll - entry.chance
		if roll < 0 then
			return entry.item_id
		end
	end
	return nil
end

function ItemLootMgr:ctor()
	self._entries = {}
	self._logic = nil
end

--[[
	lootGroups
		-- group1
			-- item1	10
			-- item2 	20
		-- group2
			-- item1 	40
			-- item2	50
			-- miss		10
]]
function ItemLootMgr:init()
	for _,v in ipairs(sItemLootStroes) do
		local _lootgroups = self._entries[v.id]
		if not _lootgroups then
			self._entries[v.id] = {}
			_lootgroups = self._entries[v.id]
		end

		local group = _lootgroups[v.groupId]
		if not group then
			_lootgroups[v.groupId] = clone(lootGroup)
			group = _lootgroups[v.groupId]
		end
		
		local entry = { item_id = v.item_id, chance = v.chance }
		table.insert(group._chances,entry)
	end
end

function ItemLootMgr:Loot(lootId)
	local groups = self._entries[lootId]
	if lootGroup then
		return self:Process(groups)
	end
	return nil
end

function ItemLootMgr:Process(groups)
	local lootItems = {} 
	for _,group in pairs(groups) do
		local itemId = group:Roll()
		if itemId then
			lootItems[#lootItems+1] = itemId
		end
	end
	return lootItems
end

function ItemLootMgr:setGameLogic(logic)
	self._logic = logic
end

function ItemLootMgr:LootInMap(lootId,object)
	local loot = self:Loot(lootId)
	for _,id in pairs(loot) do
		self._logic:addItem(id,object)
	end
end

return ItemLootMgr