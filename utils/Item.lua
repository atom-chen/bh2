local Item = class("Item")
Item.__index = Item

--[[
字段：
id,
随机属性1-5，{stat1 = {id,val}}

item的强化实质上洗练，即对随机属性的强化
]]

function Item:ctor()

end

function Item:Load(t)
	self._id = t.id
	self._entry = sItemStore[self._id]
	self._randomStats = {} 
	local temp = t.randomStats
	if temp ~= "" then
		local t = string.split(temp,",")
		for i = 1,#t do
			local n = tonumber(t[i])
			if n and n > 0 then
				self._randomStats[#self._randomStats+1] = n
			end
		end
	end
	self._quality = t.quality or 0
end

function Item:Create(id)
	assert(id,"ERROR: Nil ItemId")
	self._id = id
	self._entry = sItemStore[self._id]
	self._randomStats = {}
	self._quality = self._entry.quality
end

function Item:getId()
	return self._id
end

function Item:getEntry()
	return sItemStore[self._id]
end

function Item:getName()
	local entry = sItemStore[self._id]
	if entry then
		return entry.name
	end
	return "NoName"
end

function Item:getDesc()
	local entry = sItemStore[self._id]
	if entry then
		return entry.desc
	end
	return "Nodesc"
end

function Item:getProps1()
	local props = 
	{
		hp = 0,
		attack = 0,
		defence = 0,
		magic_defence = 0,
		single_magicdefence = 0,
		crit = 0,
		hit = 0,
		addSpellLevel = 0,
		addClassSpellLevel = 0,
		addAllSpellLevel = 0,
		addTreatureLoot = 0,
		kb = 0,
		defenceKb = 0,
		kd = 0,
		defenceKd = 0,
		addDmgTokd = 0,
		addDmgToClass = 0,
		addDefenceToClass= 0,
		strikeDefence = 0,
		strikeDefencePct = 0,
	}

	local ret = 
	{
		[1] = {hp = 0},
		[2] = {attack = 0},
		[3] = {defence = 0},
		[4] = {magic_defence = 0},
		[5] = {single_magicdefence = 0},
		[6] = {crit = 0},
		[7] = {hit = 0},
		[8] = {critdmg = 0},
		[9] = {addSpellLevel = 0},
		[10] = {addClassSpellLevel = 0},
		[11] = {addAllSpellLevel = 0},
		[12] = {addTreatureLoot = 0},
		[13] = {kb = 0},
		[14] = {defenceKb = 0},
		[15] = {kd = 0},
		[16] = {defenceKd = 0},
		[17] = {addDmgTokd = 0},
		[18] = {addDmgToClass = 0},
		[19] = {addDefenceToClass= 0},
		[20] = {strikeDefence = 0},
		[21] = {strikeDefencePct = 0},
	}

	local function calcProps(propId,value)
		assert(type(propId) == "number" and type(value) == "number")

		local t = ret[propId]
		for k,v in pairs(t) do
			t[k] = v + value
			break
		end
	end

	for i = 1,#self._randomStats do
		local entry = sItemRandomWordStore[self._randomStats[i]]
		assert(entry,"nil item random word entry,id:"..self._randomStats[i])
		local prop = entry.word_name
		local value = entry.word_value
		calcProps(prop,value)
	end

	dump(ret)

	return ret
end

function Item:getProps()
	local ret = {}
	ret[ItemProps.hp] = self:getHp()
	ret[ItemProps.attack] = self:getAttack()
	ret[ItemProps.defence] = self:getDefence()

	for i = 1,#self._randomStats do
		local entry = sItemRandomWordStore[self._randomStats[i]]
		assert(entry,"nil item random word entry,id:"..self._randomStats[i])
		local prop = entry.word_name
		local value = entry.word_value
		if not ret[prop] then
			ret[prop] = 0
		end
		ret[prop] = ret[prop] + value
	end

	dump(ret)

	return ret
end

function Item:getHp()
	local entry = sItemStore[self._id]
	if entry then
		return entry.hp
	end
	return 0
end

function Item:getDisplay()
	local entry = sItemStore[self._id]
	if entry then
		return entry.icon
	end
	return "item/img_shiping_0.png"
end

function Item:setQuality(q)
	self._quality = q
end

function Item:getQuality()
	return self._quality
end

function Item:getQualityDisplay()
	
end

function Item:getAttack()
	local entry = sItemStore[self._id]
	if entry then
		return entry.attack
	end
	return 0
end

function Item:getDefence()
	local entry = sItemStore[self._id]
	if entry then
		return entry.defence
	end
	return 0
end

function Item:getLevel()
	return self._entry.level
end

function Item:getReqLevel()
	local entry = sItemStore[self._id]
	if entry then
		return entry.reqLv
	end
	return 0
end

function Item:getSellPrice()
	local entry = sItemStore[self._id]
	if entry then
		return entry.sellprice
	end
	return 0
end

function Item:getForgePrice()
	assert(self:isVerify(),"ERROR:没鉴定过的装备，不能获取强化价格")
	local price = 0
	for i = 1,#self._randomStats do
		--每个字段Id强化需要多少金钱
		local wordid = self._randomStats[i]
		local entry = sItemRandomWordStore[wordid]
		if entry.next_id ~= 0 then
			price = price + sItemRandomWordStore[wordid].forge_price
		end
	end
	return price
end

function Item:setRandomStats(t)
	self._randomStats = {}
	for k,v in pairs(t) do
		self._randomStats[#self._randomStats + 1] = tonumber(v)
	end
end

function Item:getRandomStats()
	return self._randomStats
end

function Item:isRandomly()
	return self._entry.bRandomly == 1
end

function Item:getVerifyPrice()
	assert(self._quality >= Quality.S and self._quality <= Quality.E)
	local ret = 0
	if self:isVerify() then
		return ret
	end

	local entry = sItemVerifyStore[self:getLevel()]
	assert(entry)
	if self._quality == Quality.S then
		ret = entry.S
	elseif self._quality == Quality.A then
		ret = entry.A
	elseif self._quality == Quality.B then
		ret = entry.B
	elseif self._quality == Quality.C then
		ret = entry.C
	elseif self._quality == Quality.D then
		ret = entry.D
	elseif self._quality == Quality.E then
		ret = entry.E
	end	
	return ret
end

function Item:isVerify()
	--如果品质不是白，并且无随机属性，才可以鉴定
	if self._quality == Quality.E then
		--品质为白是没有随机属性的，这里处理为认定品质为白被鉴定过
		return true
	end

	if #self._randomStats > 0 then
		return true
	end
	return false
end

function Item:Verify()
	--如果品质不是白，并且无随机属性，才可以鉴定
	if self:isVerify() then
		return
	end

end

function Item:getSlot()
	return self._entry.equip_slot
end

function Item:getCategory()
	return 1
end

function Item:GetData()
	local retData = {}
	retData["id"] = self._id
	retData["quality"] = self._quality

	local randomStats = ""
	for i = 1,#self._randomStats do
		if self._randomStats[i] ~= 0 then
			if i ~= #self._randomStats then
				randomStats = randomStats .. tostring(self._randomStats[i]) .. ","
			else
				randomStats = randomStats .. tostring(self._randomStats[i])
			end
		end
	end

	retData["randomStats"] = randomStats

	return retData
end

function Item:setEquip(bequip)
	self._bEquip = bequip
end

function Item:IsEquipped()
	return self._bEquip
end

return Item