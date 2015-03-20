local HeroModel = class("HeroModel")

HeroModel.__index = HeroModel

function HeroModel:ctor()
	self._teamData = StorageMgr:getTeamDataMgr()
	self._bag = StorageMgr:getBagDataMgr()
end

function HeroModel:setSelectHero(idx)
	local battleSeq = self._teamData:getBattleSeq()
	assert(battleSeq[idx],"Invalid idx in battleSeq")
	self._selectHeroId = battleSeq[idx]
	self._selHero = StorageMgr:getPlayer(self._selectHeroId)
end

function HeroModel:getSelectHeroId()
	return self._selectHeroId
end

function HeroModel:getSelectHero()
	return self._selHero
end

function HeroModel:getCoin()
	return self._teamData:getCoin()
end

function HeroModel:modifyCoin(coin)
	self._teamData:modifyCoin(coin)
end

function HeroModel:hireHero(class)
	local entry = sHireCostStore[class]
	local cost = entry.cost
	if self:getCoin() < cost then
		return errorCode.NOT_ENOUGH_COIN
	end
	if StorageMgr:hasPlayer(class) then
		return errorCode.HAS_HIRED_PLAYER
	end

	self._teamData:modifyCoin(-cost)

	StorageMgr:CreatePlayer(class)

	StorageMgr:Save()

	return 0
end

function HeroModel:getPlayerIdInTeamByPos(pos)
	return self._teamData:getPlayerIdInTeamByPos(pos)
end

function HeroModel:opHeroBattleTeam(class,bJoin)
	if not StorageMgr:hasPlayer(class) then
		return errorCode.PLAYER_UNLOCK
	end

	if bJoin == 1 then --入队
		if self._teamData:isPlayerInBattleSeq(class) then
			return errorCode.PLAYER_ALREADY_IN_TEAM
		end

		self._teamData:addBattleSeq(class)
	elseif bJoin == 0 then
		self._teamData:removeFromBattleSeq(class)
	end

	return 0
end

function HeroModel:getBattleTeam()
	return self._teamData:getBattleSeq()
end

local function getVerifyPrice(level,quality)
	assert(quality >= Quality.S and quality <= Quality.E)
	local ret = 0
	local entry = sItemVerifyStore[level]
	assert(entry)
	if quality == Quality.S then
		ret = entry.S
	elseif quality == Quality.A then
		ret = entry.A
	elseif quality == Quality.B then
		ret = entry.B
	elseif quality == Quality.C then
		ret = entry.C
	elseif quality == Quality.D then
		ret = entry.D
	elseif quality == Quality.E then
		ret = entry.E
	end	
	return ret
end

local function getLootCountByQuality(quality)
	local ret = 0
	if quality == Quality.S then
		ret = 5
	elseif quality == Quality.A then
		ret = 4
	elseif quality == Quality.B then
		ret = 3
	elseif quality == Quality.C then
		ret = 2
	elseif quality == Quality.D then
		ret = 1
	elseif quality == Quality.E then
		ret = 0
	end	
	return ret
end

function HeroModel:verifyItem(item)
	assert(item and iskindof(item,"Item"),"ERROR:WROND TYPE")

	if not self._bag:hasItem(item) then
		return errorCode.NOT_EXIST_ITEM
	end

	if item:isVerify() then
		return errorCode.ITEM_HAS_BEEN_VERIFY
	end

	if item:isRandomly() == false then
		return errorCode.ITEM_ISNOT_RANDOMLY
	end

	local price = getVerifyPrice(item:getLevel(),item:getQuality())
	if self:getCoin() < price then
		return errorCode.NOT_ENOUGH_COIN
	end

	local quality = item:getQuality()
	local lootid = item:getLevel()
	local lootCount = getLootCountByQuality(quality)
	cclog("loot word count:"..lootCount)
	local words = LootMgr:Loot(lootid,lootCount)
	assert(#words == lootCount,"掉落字段数量非法")

	for i = 1,#words do
		cclog("物品掉落随机属性"..i..":"..words[i])
	end
	item:setRandomStats(words)

	StorageMgr:Save()

	return 0
end

function HeroModel:hasItemInBag(item)
	assert(item and iskindof(item,"Item"),"ERROR:WROND TYPE")

	if self._bag:hasItem(item) then
		return true
	end

	return false
end

function HeroModel:hasItemInEquipSlot(item)
	assert(item and iskindof(item,"Item"),"ERROR:WROND TYPE")

	if self._selHero:hasEquip(item) then
		return true
	end

	return false
end

function HeroModel:sellItem(item)
	assert(item and iskindof(item,"Item"),"ERROR:WROND TYPE")

	if not self._bag:hasItem(item) and not self._selHero:hasEquip(item) then
		return errorCode.NOT_EXIST_ITEM
	end

	local price = item:getSellPrice()
	if self._selHero:hasEquip(item) then
		self._selHero:unEquip(item:getSlot())
	else
		local ret = self._bag:removeItem(item)
		assert(ret,"remove item from bag fail")
	end
	
	self:modifyCoin(price)
	
	StorageMgr:Save()

	cclog("出售装备，分发事件。。。。。。。")
	NotifyCenter:dispatchEvent({name = Events.EQUIP_CHANGE})

	return 0
end

function HeroModel:getTotalSlots()
	return self._bag:getTotalSlots()
end

function HeroModel:getOwnSlots()
	return self._bag:getOwnSlots()
end

function HeroModel:getBagItem(idx)
	return self._bag:getItem(idx)
end

function HeroModel:equipItem(item)
	assert(item and iskindof(item,"Item"),"ERROR:WROND TYPE")
	--判定等级？？？？
	if item:getReqLevel() > self._selHero:getLevel() then
		return errorCode.PLAYER_EQUIP_NOT_ENOUGH_LEVEL
	end

	if item:isVerify() == false then
		return errorCode.CANNOT_EQUIP_UNVERIFY_ITEM
	end

	assert(item:getSlot()>=EquipSlot.head and item:getSlot()<=EquipSlot.fashion2)
	
	local slot = item:getSlot()
	local equipItem = self._selHero:getEquip(slot)
	
	--以下顺序不能乱，不然会出错！！！！！
	if equipItem then --移掉人物身上装备1
		self._selHero:unEquip(slot)
	end

	--移掉背包里将要装备的物品2
	self._bag:removeItem(item)

	--穿上物品2
	self._selHero:Equip(item)

	if equipItem then --把装备1放入背包
		self._bag:addItem(equipItem)
	end

	StorageMgr:Save()

	cclog("穿上装备，分发事件。。。。。。。")
	NotifyCenter:dispatchEvent({name = Events.EQUIP_CHANGE,equipId = item:getId(),event = 1})

	return 0
end

function HeroModel:unEquipItem(item)
	assert(item and iskindof(item,"Item"),"ERROR:WROND TYPE")
	
	if self._selHero:hasEquip(item) == false then
		return errorCode.PLAYER_DO_NOT_HAS_EQUIP
	end

	if self._bag:getItemCount() >= self._bag:getOwnSlots() then
		return errorCode.NOT_ENOUGH_BAG_SLOTS
	end

	assert(item:getSlot()>=EquipSlot.head and item:getSlot()<=EquipSlot.fashion2)
	
	self._selHero:unEquip(item:getSlot())

	self._bag:addItem(item)

	cclog("装备变化，分发事件。。。。。。。")
	NotifyCenter:dispatchEvent({name = Events.EQUIP_CHANGE})

	return 0
end

function HeroModel:unequipItem(id)
	-- body
end

function HeroModel:forgeItem(item)
	assert(item and iskindof(item,"Item"),"ERROR:WROND TYPE")

	if item:getQuality() == Quality.E then 
		return errorCode.ITEM_SHOULD_NOT_BE_FORGED
	end

	local price = item:getForgePrice()
	if self:getCoin() < price then
		return errorCode.NOT_ENOUGH_COIN
	end

	self._teamData:modifyCoin(-price)

	--等级判定还没写！！！！！！！！！！！！！！！！！！！

	local stats = item:getRandomStats()
	local newStats = {}
	for i = 1,#stats do
		--每个字段Id强化需要多少金钱
		local wordid = stats[i]
		local nextId = sItemRandomWordStore[wordid].next_id
		assert(nextId ~= 0,"ERROR:Invaild NEXT word id")
		newStats[i] = nextId
	end

	item:setRandomStats(newStats)

	StorageMgr:Save()

	return 0
end

function HeroModel:upgradeSpell(spellId)
	local srcNode = gSpellChain[spellId]
	assert(srcNode,"ERROR:Invaild spellId(" ..spellId ..")in SpellChain")
	local nextSpellId = gFirstSpellChain[srcNode.firstId][srcNode.rank + 1]
	assert(nextSpellId,"ERROR:can find spellId(".. spellId ..")'s nextSpellId")
	if srcNode.reqLv > self._selHero:getLevel() then
		return errorCode.PLAYER_NOT_ENOUGH_LEVEL
	end
	if srcNode.costType == CostType.COIN and srcNode.cost > self._teamData:getCoin() then
		return errorCode.NOT_ENOUGH_COIN
	end

	self._teamData:modifyCoin(-srcNode.cost)

	cclog("upgradeSpell:"..spellId)
	self._selHero:upgradeSpell(spellId)

	cclog("技能升级，分发事件。。。。。。。")
	NotifyCenter:dispatchEvent({name = Events.UPGRADE_SPELL,spellId = nextSpellId})

	StorageMgr:Save()

	return 0
end

return HeroModel