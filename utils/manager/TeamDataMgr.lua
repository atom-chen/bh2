local TeamDataMgr = class("TeamDataMgr")
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

function TeamDataMgr:ctor()
	if not __allowInstance then
		error("TeamDataMgr is a singleton")
	end

	self:Init()
end

function TeamDataMgr:Init()
	self:Reset()
end

function TeamDataMgr:Reset()
	self._name = HexData.new("")
	self._coin = HexData.new(0)
    self._diamond = HexData.new(0)
    self._level = HexData.new(0)
    self._exp = HexData.new(0)
    self._battleSeq = {}
    self._equipBag = {}
    self._cardBag = {}
end

function TeamDataMgr:getInstance( )
	if not __instance then
		__allowInstance = true
		__instance = TeamDataMgr.new()
		__allowInstance = false
	end

	return __instance
end

function TeamDataMgr:setMgr(mgr)
	self._mgr = mgr
end

function TeamDataMgr:getMgr()
	assert(self._mgr,"Error:TeamDataMgr should have a mgr")
	return self._mgr
end

function TeamDataMgr:Load(jsonValue)
	cclog("----------TeamDataMgr:Load")
	self._name = HexData.new((jsonValue["name"]) or "")
	self._coin = HexData.new(jsonValue["coin"] or 0)
    self._diamond = HexData.new(jsonValue["diamond"] or 0)

    local temp = string.split(jsonValue["battleSeq"],",")
    for i = 1,#temp do
    	local n = tonumber(temp[i])
    	if n and n > 0 then
    		self._battleSeq[#self._battleSeq + 1] = n
    	end
    end
    
end

function TeamDataMgr:GetData()
	local retData = {}

	retData["name"] = self:getName()
	retData["coin"] = self:getCoin()
	retData["diamond"] = self:getDiamond()
	
	local strBattleSeq = ""
	for i = 1,#self._battleSeq do
		if i ~= #self._battleSeq then
			strBattleSeq = strBattleSeq .. tostring(self._battleSeq[i]) .. ","
		else
			strBattleSeq = strBattleSeq .. tostring(self._battleSeq[i])
		end
	end
	retData["battleSeq"] = strBattleSeq

	return retData
end

function TeamDataMgr:Save()
	assert(self._mgr,"Error:TeamDataMgr should have a mgr")
	self._mgr:Save()
end

function TeamDataMgr:getName()
	return self._name:GetString()
end

function TeamDataMgr:setName(name)
	self._name:setValue(tostring(name))

	self:Save()
end

function TeamDataMgr:getCoin()
	return self._coin:GetInt()
end

function TeamDataMgr:setCoin(coin)
	assert(type(coin)=="number","ERROR:Invaild param")
	cclog("设置金钱数目："..coin)
	self._coin:setValue(coin)

	cclog("金钱变化，分发事件。。。。。。。")
	NotifyCenter:dispatchEvent({name = Events.MONEY_CHANGE,coin = coin})

	self:Save()
end

function TeamDataMgr:modifyCoin(coin)
	local ownCoin = self:getCoin()

	local mod = ownCoin + coin
	assert(mod >= 0, "ERROR:modify Coin")
	self:setCoin(mod)
end

function TeamDataMgr:getDiamond() 
	return self._diamond:GetInt()
end

function TeamDataMgr:setDiamond(diamond) 
	assert(type(diamond)=="number","ERROR:Invaild param")
	self._diamond:setValue(diamond)

	self:Save()
end

function TeamDataMgr:addBattleSeq(id,index)
	index = index or table.nums(self._battleSeq) + 1
	if table.keyof(self._battleSeq,id) then
		assert(false)
		return
	end
	table.insert(self._battleSeq,index,id)
end

function TeamDataMgr:removeFromBattleSeq(id,index)
	local index = table.keyof(self._battleSeq,id)
	if not index then
		return
	end
	table.remove(self._battleSeq,index)
end

function TeamDataMgr:getBattleSeq()
	return self._battleSeq
end

function TeamDataMgr:isPlayerInBattleSeq(class)
	if table.keyof(self._battleSeq,class) then
		dump(self._battleSeq)
		return true
	end

	return false
end

function TeamDataMgr:getPlayerIdInTeamByPos(pos )
	return self._battleSeq[pos]
end

function TeamDataMgr:addItem(itemId)
	
end

function TeamDataMgr:removeItem(item)
	
end

function TeamDataMgr:getItems()
	return self._items or {}
end

function TeamDataMgr:hasItem(itemId)
	return true
end

return TeamDataMgr