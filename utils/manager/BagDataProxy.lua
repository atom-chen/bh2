local BagDataProxy = class("BagDataProxy")

local __instance = nil
local __allowInstance = nil

--背包信息：背包总格子，已开启的格子数，拥有的物品({物品1，数量}，{物品2，数量})

function BagDataProxy:ctor()
    --BagDataProxy.super.ctor(self, "BagDataProxy")
    if not __allowInstance then
		error("BagDataProxy is a singleton")
	end
end

function BagDataProxy:getInstance( )
	if not __instance then
		__allowInstance = true
		__instance = BagDataProxy.new()
		__allowInstance = false
	end

	return __instance
end

function BagDataProxy:setMgr(mgr)
	self._mgr = mgr
end

function BagDataProxy:getMgr()
	assert(self._mgr,"Error:BagDataProxy should have a mgr")
	return self._mgr
end

function BagDataProxy:Load(jsonValue)
	cclog("----------BagDataProxy:Load")

	self._totalSlots = HexData.new((jsonValue["totalSlots"]) or 0)
	self._ownSlots = HexData.new(jsonValue["ownSlots"] or 0)

	self._item = HexData.new(jsonValue["item"] or 0)
end

function BagDataProxy:Save()
	assert(self._mgr,"Error:BagDataProxy should have a mgr")
	self._mgr:Save()
end

function BagDataProxy:addItem(itemId,count)
	--self._item[#self._item + 1] = {itemId,count}
	
end

function BagDataProxy:removeItem( itemId,count )
	
end

return BagDataProxy