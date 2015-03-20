local Player = class("Player")
local HexData = require("utils.HexData")

--[[
英雄信息：装备，等级，经验，
		 (属性：生命值,攻击，防御。。。)，已学技能，未学技能
]]

EquipSlot = 
{
	head 	= 1,
	weapon  = 2,
	cloth   = 3,
	foot 	= 4,
	fashion1 = 5,
	fashion2 = 6
}

local Item = require("utils.Item")

function Player:ctor(id)
	self:Init()
end

function Player:Init(data)
	cclog("Player Init..........")
	self:Reset()
end

function Player:Reset()
	self._id = HexData.new(0)
	self._level = HexData.new(0)
	self._exp = HexData.new(0)
    self._nextLvExp = HexData.new(0)
    self._spells = {}
    self._props = {}
    self._equips = {}
end

function Player:Create(id)
	--根据id查playercreateinfo表
	local entry = sPlayerCreateInfoStore[id]
	local t = {
		id = entry.id,
		level = 1,
		exp = 0,
		nextLvExp = sLevelExpStore[2].exp or 0,
		props = {
			hp = entry.hp,
			atk = entry.atk,
			defence = entry.defence,
			kdValue = entry.kdValue, -- knockdown value
			kbValue = entry.kbValue, -- knockback value
			resistKd = entry.resistKd,	-- resist knockdown
			resistKb = entry.resistKb,	-- resist knockback
			recoverKd = entry.recoverKd,	-- 每0.2s回复 knockdown 的值
			recoverKb = entry.recoverKb, -- 每0.2s回复 knockback 的值

			downTime = entry.downTime,					-- 躺在地上的时间
		},
		initSpells = entry.skill
	}

	self:Load(t,true)
end

function Player:Load(t,bCreate)
	self:Reset()
	cclog("----------Player:Load")
	self._id = HexData.new(t.id or 0)
	self._level = HexData.new(t.level or 0)
	self._exp = HexData.new(t.exp or 0)
    self._nextLvExp = HexData.new(t.nextLvExp or 0)
    cclog("player next lv exp:"..self._nextLvExp:GetInt())
    self._initialSpells = t.initSpells or {}
    
    local tempEquipInfo = t.equips or {}
    for k,v in pairs(tempEquipInfo) do
    	local id = v.id
    	local randomStats = v.randomStats
    	local item = self:CreateItem(v)
    	self:Equip(item,true)
    end
    --[[
    if t.equip1 then
    	local item1 = self:CreateItem(t.equip1)
    	self:Equip(item1)
    end]]
    --[[
    for i = 1,#EquipSlot do
    	local equip = rawget(t, "equip"..i)
    	if equip then
    		dump(equip)
    		local item1 = self:CreateItem(equip)
    		self:Equip(item1)
    	end
    end]]
    assert(self._spells)
    self._spells = t.spells or {}

    if bCreate then
    	self:learnDefaultSpells()
    end

    for i = 1,#self._spells do
    	self:learnSpell(self._spells[i])
    end


    self._props = t.props or {}

    self:UpdateProps()

    self:GetData()
end

function Player:GetData()
	local ret = {}
	ret["id"] = self:getId()
	ret["level"] = self:getLevel()
	ret["exp"] = self:getExp()
	ret["nextLvExp"] = self:getNextLvExp()

	local tempEquipInfo = {}
    for i = 1,#self._equips do
    	if self._equips[i] and self._equips[i] ~= 0 then
    		local item = self._equips[i]
		    local slot = item:getSlot()
		    assert(slot == i)
			local itemdata = item:GetData()
			--ret["equip"..i] = itemdata
			tempEquipInfo[i] = itemdata
		end
	end
	ret["equips"] = tempEquipInfo

	ret["spells"] = self._spells
	ret["props"] = self._props

	return ret
end

function Player:getBattleData()
	local ret = {}
	ret["id"] = self:getId()
	ret["attack"] = self:getAttackSpell()
	ret["spells"] = self._spells
	ret["baseProps"] = self._props
	ret["extraProps"] = self._extraProps
	return ret
end

function Player:Save()
	assert(self._mgr,"Error:Player should have a mgr")
	self._mgr:Save()
end

function Player:CreateItem(equipInfo)
	local item = Item.new()
	item:Load(equipInfo)
	return item
end

function Player:getHeadIcon()
	local entry = sPlayerCreateInfoStore[self:getId()]
	return sPlayerDisplayStore[entry.display].head_icon
end

function Player:getId()
	return self._id:GetInt()
end

function Player:getAttackSpell()
	local ret= {}
	local entry = sPlayerCreateInfoStore[self:getId()]
	for i = 0,#entry.attack do
		ret[#ret + 1] = entry.attack[i]
	end
	return ret
end

function Player:getName()
	return self._name:GetString()
end

function Player:setName(name)
	self._name:setValue(tostring(name))

	self:Save()
end

function Player:getExp() 
	return self._exp:GetInt()
end

function Player:setExp(exp)
	assert(type(exp)=="number","ERROR:Invaild param")
	self._exp:setValue(exp)

	StorageMgr:Save()
end

function Player:getNextLvExp()
	return self._nextLvExp:GetInt()
end

function Player:modifyExp(exp)
	local curExp = self:getExp()

	local mod = curExp + exp
	assert(mod >= 0, "ERROR:modify Exp")
	self:setExp(mod)
end

function Player:giveExp(exp)
	if exp < 1 then
		return
	end

	local level = self:getLevel()
	if level >= 99 then
		return
	end

	local curXP = self:getExp()
	local nextLvExp = self:getNextLvExp()
	local newXP = curXP + exp

	while (newXP >= nextLvExp and level < 99) do
		newXP = newXP - nextLvExp;

		if level < 99 then
			self:giveLevel(level + 1)
		end

		level = self:getLevel()
		nextLvExp = self:getNextLvExp()
	end

	self:setExp(newXP)
end

function Player:getLevel()
	return self._level:GetInt()
end

function Player:setLevel(level)
	assert(type(level)=="number","ERROR:Invaild param")
	self._level:setValue(level)

	StorageMgr:Save()
end

function Player:giveLevel(level)
	if level == self._level then 
		return 
	end

	--得到下一等级的经验
	self._nextLvExp:setValue(sLevelExpStore[level + 1].exp or 0)

	self:setLevel(level)

	--学习技能
	self:LearnSpell()

	self:UpdateProps()
end

function Player:addSpell(spellId)
	-- body
end

function Player:removeSpell(spellId)
	-- body
end

function Player:learnDefaultSpells()
	--学习初始技能
	local initSpells = sPlayerCreateInfoStore[self:getId()].skill
	dump(initSpells)
	for i=0,#initSpells do
		local spellId = initSpells[i]
		assert(spellId)
		assert(self._spells)
		if not table.keyof(self._spells,spellId) and gSpellChain[spellId] then
			cclog("learnDefaultSpell:"..spellId)
			local node = gSpellChain[spellId]
			assert(node.prevId == 0)
			if node.reqLv <= self:getLevel() then
				self:learnSpell(spellId)
			end
		end
	end
end

function Player:LearnSpell()
	--创建Player时要学习初始技能
	--LOAD player时要学习已学会技能

	
end

function Player:learnSpell(spellId)
	assert(spellId,"ERROR:Invalid param")

	local node = gSpellChain[spellId]
	if node.reqLv > self:getLevel() then
		cclog("learn spell fail because not enough level")
		return
	end
	if table.keyof(self._spells,spellId) then
		cclog("have learned spell!!!")
		return
	end
	cclog("Player learnSpell,id:"..spellId)
	

	if node.prevId ~= 0 then
		local idx = table.keyof(self._spells,node.prevId)
		if not idx then
			assert(false,"还没学会前一条技能")
		end

		self._spells[idx] = spellId
	else
		cclog("第一次学习本链条的第一条技能："..spellId)
		local entry = sPlayerCreateInfoStore[self:getId()]
		local idx = table.keyof(entry.skill,spellId) + 1
		cclog("spell idx:"..idx)
		assert(idx,"player initial spell don't have this spellId:"..spellId)
		--assert(table.keyof(self._spells,spellId),"player has learned this spell:"..spellId)
		table.insert(self._spells,idx,spellId)
	end
	dump(self._spells)
end

function Player:upgradeSpell(spellId)
	assert(table.keyof(self._spells,spellId),"player don't have spellId:"..spellId)

	local srcNode = gSpellChain[spellId]
	assert(srcNode,"ERROR:Invaild spellId(" ..spellId ..")in SpellChain")
	local nextSpellId = gFirstSpellChain[srcNode.firstId][srcNode.rank + 1]
	assert(nextSpellId,"ERROR:can find spellId(".. spellId ..")'s nextSpellId")

	for i = 1,#self._spells do
		if self._spells[i] == spellId then
			self._spells[i] = nextSpellId
			--但是属性的变化呢？
		end
	end

	dump(self._spells,"Player spells:")

	return true
end

function Player:getLearnedSpells()
	return self._spells
end

function Player:getUnlearnSpells()
	local ret = {}
	local initSpells = sPlayerCreateInfoStore[self:getId()].skill
	for i=0,#initSpells do
		local initSpellId = initSpells[i]
		local spellId = self._spells[i+1]
		if spellId then
			if gSpellChain[spellId].firstId ~= initSpellId then
				assert(false,"spellId("..spellId..")'s firstId is "..gSpellChain[spellId].firstId..",not equals to player's initSpellId:"..initSpellId)
			end
		else
			ret[i+1] = initSpellId
		end
	end

	return ret
end

function Player:Equip( item )
	local category = item:getCategory()
	local slot = item:getSlot()
	local itemId = item:getId()
	local randomStats = item:getRandomStats()

	cclog("把武器装到武器槽"..slot)
	
	if self._equips[slot] then
		assert(false)
		--self:unEquip(slot)
	end
	self._equips[slot] = item

	--[[
	cclog("装备变化，分发事件。。。。。。。")
	NotifyCenter:dispatchEvent({name = Events.EQUIP_CHANGE})]]

	self:UpdateProps()
end

function Player:unEquip(slot)
	--从Player身上移除，再把物品加到背包
	assert(self._equips[slot],"ERROR:对应的武器槽上没有武器")
	local item = self._equips[slot]
	self._equips[slot] = nil

	self:UpdateProps()
	--StorageMgr:getBagDataMgr():addItem(item)
	--[[
	cclog("装备变化，分发事件。。。。。。。")
	NotifyCenter:dispatchEvent({name = Events.EQUIP_CHANGE})

	StorageMgr:Save()]]
end

function Player:getEquip(slot)
	return self._equips[slot]
end

function Player:hasEquip(item)
	for k,equip in pairs(self._equips) do
		if equip == item then
			return true
		end
	end

	return false
end

function Player:setHp(hp)
	self._props.hp = hp
end

function Player:getHp()
	return self._props.hp
end

function Player:getBaseHp()
	return sPlayerCreateInfoStore[self:getId()].hp
end

function Player:getBaseAttack()
	return sPlayerCreateInfoStore[self:getId()].atk
end

function Player:getBaseDefence()
	return sPlayerCreateInfoStore[self:getId()].defence
end

function Player:modifyHp(value)
	-- body
end

function Player:setDefence(d)
	self._props.defence = d
end

function Player:getDefence()
	return self._props.defence
end

function Player:modifyDefence(value)
	-- body
end

function Player:setArmor(armor)
	self._props.armor = armor
end

function Player:getArmor()
	return self._props.armor
end

function Player:modifyArmor(value)
	-- body
end

function Player:setResist()
	-- body
end

function Player:getResist()
	-- body
end

function Player:modifyResist(value)
	-- body
end

function Player:setAttack(ad)
	self._props.atk = ad
end

function Player:getAttack()
	return self._props.atk
end

function Player:modifyAttackDamage(value)
	-- body
end

function Player:setMagicPower(mp)
	-- body
end

function Player:getMagicPower()
	-- body
end

function Player:modifyMagicPower(value)
	-- body
end

--更新属性
function Player:UpdateProps()
	local basehp,baseatk,basedefence = self:getBaseHp(),self:getBaseAttack(),self:getBaseDefence()
	--面板攻击力 = ( 基础属性攻击 + 装备攻击 + 灵魂碎片攻击 )  *(装备百分比+灵魂碎片百分比+ 祈福加成百分比)
	--面板防御力 = ( 基础属性防御 + 装备防御 + 灵魂碎片防御 )  *(装备百分比+灵魂碎片百分比+ 祈福加成百分比)
	local mt = {}
	mt.__add = function (t1,t2)
		local ret = {}
		local t = {}
		if table.nums(t1) > table.nums(t2) then
			t = t1
		else
			t = t2
		end
		for k,v in pairs(t) do
			ret[k] = (t1[k] or 0) + (t2[k] or 0)
		end
		return ret
	end

	local result = {}
	for i = 1,table.nums(ItemProps) do
		result[i] = 0
	end
	setmetatable(result,mt)
	for i = 1,6 do
		local equip = self._equips[i]
		if equip then
			local retProp = equip:getProps()
			setmetatable(retProp,mt)
			result = result + retProp
		end
	end

	local newhp = basehp + result[ItemProps.hp]
	local newatk = baseatk + result[ItemProps.attack]
	local newdefence = basedefence + result[ItemProps.defence]
	self._extraProps = result

	cclog("newhp:"..newhp)
	cclog("newatk:"..newatk)
	cclog("newdefence:"..newdefence)
	self:setHp(newhp)
	self:setAttack(newatk)
	self:setDefence(newdefence)
	cclog("额外属性。。。。。")
	dump(self._extraProps)

	cclog("人物属性变化，分发事件。。。。。。。")
	NotifyCenter:dispatchEvent({name = Events.PLAYER_PROPS_CHANGE})
end

function Player:getEquipProps()
	local hp,atk,defence = 0,0,0
	for i = 1,#self._equips do
    	local item = self._equips[i]
    	if item and iskindof(item,"Item") then
		    local slot = item:getSlot()
		    assert(slot == i)
			local itemdata = item:GetData()
			--ret["equip"..i] = itemdata
			tempEquipInfo[i] = itemdata
		end
	end
end

return Player