local BagDataMgr = class("BagDataMgr")

local __instance = nil
local __allowInstance = nil
local HexData = require("utils.HexData")
local Item = require("utils.Item")
--背包信息：背包总格子，已开启的格子数，拥有的物品({物品1，数量}，{物品2，数量})

function BagDataMgr:ctor()
    --BagDataMgr.super.ctor(self, "BagDataMgr")
    if not __allowInstance then
		error("BagDataMgr is a singleton")
	end

	self:Init()
end

function BagDataMgr:getInstance( )
	if not __instance then
		__allowInstance = true
		__instance = BagDataMgr.new()
		__allowInstance = false
	end

	return __instance
end

function BagDataMgr:Init()
	self:Reset()
end

function BagDataMgr:Reset()
	self._totalSlots = HexData.new(0)
	self._ownSlots = HexData.new(0)
	self._items = {}
end

function BagDataMgr:setMgr(mgr)
	self._mgr = mgr
end

function BagDataMgr:getMgr()
	assert(self._mgr,"Error:BagDataMgr should have a mgr")
	return self._mgr
end

function BagDataMgr:Load(jsonValue)
	cclog("----------BagDataMgr:Load")

	self._totalSlots = HexData.new((jsonValue["totalSlots"]) or 0)
	self._ownSlots = HexData.new(jsonValue["ownSlots"] or 0)

	--self._item = HexData.new(jsonValue["items"] or 0)

	local temp = jsonValue["items"] or {}
    for i = 1,#temp do
    	local item = Item.new()
		item:Load(temp[i])
    	self._items[#self._items + 1] = item
    end
end

function BagDataMgr:GetData()
	local ret = {}
	ret["totalSlots"] = self:getTotalSlots()
	ret["ownSlots"] = self:getOwnSlots()
		
	local temp = {}
	for i = 1,#self._items do
		local itemdata = self._items[i]:GetData()
		temp[i] = itemdata
	end
	ret["items"] = temp

	return ret
end

function BagDataMgr:Save()
	assert(self._mgr,"Error:BagDataMgr should have a mgr")
	self._mgr:Save()
end

function BagDataMgr:modifyTotalSlots(count)
	local mod = self:getTotalSlots() + count

	self:setTotalSlots(mod)
end

function BagDataMgr:setTotalSlots(count)
	assert(type(count)=="number","ERROR:Invaild param")
	cclog("设置总格子数目："..count)
	self._totalSlots:setValue(count)

	--cclog("格子变化，分发事件。。。。。。。")
	--NotifyCenter:dispatchEvent({name = Events.MONEY_CHANGE,coin = count})

	self:Save()
end

function BagDataMgr:getTotalSlots()
	return self._totalSlots:GetInt()
end

function BagDataMgr:modifyOwnSlots(count)
	local mod = self:getOwnSlots() + count
	if mod < 0 then
		mod = 0
	elseif mod > self:getTotalSlots() then
		mod = self:getTotalSlots()
	end

	self:setOwnSlots(mod)
end

function BagDataMgr:setOwnSlots(count)
	assert(type(count)=="number","ERROR:Invaild param")
	cclog("设置拥有的格子数目："..count)
	self._ownSlots:setValue(count)

	--cclog("格子变化，分发事件。。。。。。。")
	--NotifyCenter:dispatchEvent({name = Events.MONEY_CHANGE,coin = count})

	self:Save()
end

function BagDataMgr:getOwnSlots()
	return self._ownSlots:GetInt()
end

function BagDataMgr:getItem(idx)
	if idx <= #self._items then
		return self._items[idx]
	end

	return nil
end

function BagDataMgr:hasItem(item)
	local idx = table.keyof(self._items,item)
	if table.keyof(self._items,item) then
		return idx
	end
	return nil
end

function BagDataMgr:addItem(item)
	if iskindof(item,"Item") == false then
		assert(false,"ERROR:Invaild param,should be TYPE(Item)")
		return
	end
	if table.nums(self._items) >= self:getOwnSlots() then
		cclog("没有足够的背包空间存储物品")
		return errorCode.NOT_ENOUGH_BAG_SLOTS
	end

	self._items[#self._items + 1] = item

	self:Save()
end

function BagDataMgr:LootItem(itemId)
	assert(type(itemId)=="number","ERROR:Invalid param")
	if table.nums(self._items) >= self:getOwnSlots() then
		cclog("没有足够的背包空间存储物品")
		return errorCode.NOT_ENOUGH_BAG_SLOTS
	end

	local item = Item.new()
	item:Create(itemId)
	
	local entry = sItemStore[itemId]
	if entry.bRandomly == 1 then
		local lootQuality = Quality.E
		local level = entry.level
		
		local qualityEntry = sLootQualityStore[level]

		for i = 0,#qualityEntry.quality do
			local chance = qualityEntry.quality[i] * GET_TREATURE_VALUE/100
			math.newrandomseed()
			local roll = math.random(1,100)
			roll = roll/100
			cclog("loot item,random roll:"..roll)
			roll = roll - chance
			if roll < 0 then
				lootQuality = i+1
				break
			end
		end

		item:setQuality(lootQuality)

		cclog("Loot Itemid:"..itemId..",loot quality:"..lootQuality)
	else
		
	end

	self:addItem(item)
end

function BagDataMgr:addItemId(itemId,count)
	assert(type(itemId)=="number","ERROR:Invalid param")
	if table.nums(self._items) >= self:getOwnSlots() then
		cclog("没有足够的背包空间存储物品")
		return errorCode.NOT_ENOUGH_BAG_SLOTS
	end
	local item = Item.new()
	item:Create(itemId)
	self._items[#self._items + 1] = item--{itemId,count}

	self:Save()
end

function BagDataMgr:removeItem( item )
	--[[
	cclog("从背包移除物品")
	local idx = table.keyof(self._items,item)
	if idx then
		cclog("移除成功")
		table.remove(self._items,idx)
		dump(self._items)
		cclog("装备变化，分发事件。。。。。。。")
		NotifyCenter:dispatchEvent({name = Events.EQUIP_CHANGE})
		return true
	end
	cclog("移除失败")
	assert(false)
	return false]]

	local removecount = table.removebyvalue(self._items,item,true)
	if removecount > 0 then
		cclog("移除成功,移除后背包中物品个数"..table.nums(self._items))
		return true
	end
	assert(false,"移除物品失败")
	return false
end

function BagDataMgr:getItemCount()
	return table.nums(self._items)
end

function BagDataMgr:removeItemByIdx( idx )
	-- body
end

return BagDataMgr