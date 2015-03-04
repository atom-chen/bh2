local HeroDataProxy = class("HeroDataProxy")
local HexData = require("utils.HexData")

local __instance = nil
local __allowInstance = nil

--[[
英雄信息：钻石，金币，复活卷轴，装备，等级，经验，
		 (属性：生命值,攻击，防御。。。)，已学技能，未学技能
]]

EquipSlot = 
{
	head = 1,
	weapon = 2,
	cloth = 3,
	foot = 4
}

function HeroDataProxy:ctor()
	if not __allowInstance then
		error("HeroDataProxy is a singleton")
	end

	self:Init()
end

function HeroDataProxy:Init()
	self._name = HexData.new("")
	self._coin = HexData.new(0)
    self._diamond = HexData.new(0)
    self._level = HexData.new(0)
    self._exp = HexData.new(0)
end

function HeroDataProxy:Reset()
	self._name = HexData.new("")
	self._coin = HexData.new(0)
    self._diamond = HexData.new(0)
    self._level = HexData.new(0)
    self._exp = HexData.new(0)
end

function HeroDataProxy:getInstance( )
	if not __instance then
		__allowInstance = true
		__instance = HeroDataProxy.new()
		__allowInstance = false
	end

	return __instance
end

function HeroDataProxy:setMgr(mgr)
	self._mgr = mgr
end

function HeroDataProxy:getMgr()
	assert(self._mgr,"Error:HeroDataProxy should have a mgr")
	return self._mgr
end

function HeroDataProxy:Load(jsonValue)
	cclog("----------HeroDataProxy:Load")
	self._name = HexData.new((jsonValue["name"]) or "")
	self._coin = HexData.new(jsonValue["coin"] or 0)
    self._diamond = HexData.new(jsonValue["diamond"] or 0)
    self._level = HexData.new(jsonValue["level"] or 0)
    self._exp = HexData.new((jsonValue["exp"]) or 0)
end

function HeroDataProxy:Save()
	assert(self._mgr,"Error:HeroDataProxy should have a mgr")
	self._mgr:Save()
end

function HeroDataProxy:getName()
	return self._name:GetString()
end

function HeroDataProxy:setName(name)
	self._name:setValue(tostring(name))

	self:Save()
end

function HeroDataProxy:getCoin()
	return self._coin:GetInt()
end

function HeroDataProxy:setCoin(coin)
	assert(type(coin)=="number","ERROR:Invaild param")
	self._coin:setValue(coin)

	self:Save()
end

function HeroDataProxy:getDiamond() 
	return self._diamond:GetInt()
end

function HeroDataProxy:setDiamond(diamond) 
	assert(type(diamond)=="number","ERROR:Invaild param")
	self._diamond:setValue(diamond)

	self:Save()
end

function HeroDataProxy:getExp() 
	return self._exp:GetInt()
end

function HeroDataProxy:setExp(exp)
	assert(type(exp)=="number","ERROR:Invaild param")
	self._exp:setValue(exp)

	self:Save()
end

function HeroDataProxy:getLevel()
	return self._level:GetInt()
end

function HeroDataProxy:setLevel(level)
	assert(type(level)=="number","ERROR:Invaild param")
	self._level:setValue(level)

	self:Save()
end

function HeroDataProxy:levelUp()
	-- body
end

function HeroDataProxy:addSpell(spellId)
	-- body
end

function HeroDataProxy:removeSpell(spellId)
	-- body
end

function HeroDataProxy:learnSpell(spellId)
	-- body
end

function HeroDataProxy:getLearnedSpells()
	-- body
end

function HeroDataProxy:getUnlearnSpells()
	-- body
end

function HeroDataProxy:equip( slot,item )
	-- body
end

function HeroDataProxy:unEquip(slot)
	-- body
end

function HeroDataProxy:getEquip(slot)
	-- body
end

function HeroDataProxy:setHp(hp)
	-- body
end

function HeroDataProxy:getHp()
	-- body
end

function HeroDataProxy:modifyHp(value)
	-- body
end

function HeroDataProxy:setArmor(armor)
	-- body
end

function HeroDataProxy:getArmor()
	-- body
end

function HeroDataProxy:modifyArmor(value)
	-- body
end

function HeroDataProxy:setResist()
	-- body
end

function HeroDataProxy:getResist()
	-- body
end

function HeroDataProxy:modifyResist(value)
	-- body
end

function HeroDataProxy:setAttackDamage(ad)
	-- body
end

function HeroDataProxy:getAttackDamage()
	-- body
end

function HeroDataProxy:modifyAttackDamage(value)
	-- body
end

function HeroDataProxy:setMagicPower(mp)
	-- body
end

function HeroDataProxy:getMagicPower()
	-- body
end

function HeroDataProxy:modifyMagicPower(value)
	-- body
end

return HeroDataProxy