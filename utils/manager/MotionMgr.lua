--local MgrBase = require("utils.manager.MgrBase")
local MotionMgr = class("MotionMgr")--, MgrBase)

local HexData = require("utils.HexData")

local __instance = nil
local __allowInstance = nil

--[[
	1.要把感兴趣的行为都给提取出来
	2.行为是累积性的（成就型）还是每日型的（新的一天都重新统计此行为，每日任务型）
]]

MotionEvents = {
	KILL_MONSTER = "KILL_MONSTER",
    PLAYER_DEAD_EVENT = "PLAYER_DEAD_EVENT",
}

function MotionMgr:ctor()
    --MotionMgr.super.ctor(self, "MotionMgr")
    --cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
    if not __allowInstance then
		error("MotionMgr is a singleton")
	end

	--NotifyCenter:addEventListener(MotionEvents.KILL_MONSTER, handler(self,self.killMonster))
end

function MotionMgr:getInstance( )
	if not __instance then
		__allowInstance = true
		__instance = MotionMgr.new()
		__allowInstance = false
	end

	return __instance
end

function MotionMgr:setMgr(mgr)
	self._mgr = mgr
end

function MotionMgr:getMgr()
	assert(self._mgr,"Error:MotionMgr should have a mgr")
	return self._mgr
end

function MotionMgr:Load(jsonValue)
	cclog("----------MotionMgr:Load")

	--每日任务型字段
	self._skillUpgrade = HexData.new((jsonValue["skillUpgrade"]) or 0)
	self._equipUpgrade = HexData.new(jsonValue["equipUpgrade"] or 0)
    self._passStage = HexData.new(jsonValue["passStage"] or 0)
    self._passChapter = HexData.new(jsonValue["passChapter"] or 0)
    self._killMonster = HexData.new((jsonValue["killMonster"]) or 0)

    --成就型字段
end

function MotionMgr:Save()
	assert(self._mgr,"Error:MotionMgr should have a mgr")
	self._mgr:Save()
end

function MotionMgr:skillUpgrade()
	self._skillUpgrade:setValue(self._skillUpgrade:GetInt() + 1)

	self:Save()

	--通知一下QuestMgr 和 AchevementMgr
	--QuestMgr:dispatchEvent({name = "SKILL_UPGRADE"})
	--AchevementMgr:dispatchEvent({name = "SKILL_UPGRADE"})
end

function MotionMgr:killMonster()
	self._killMonster:setValue(self._killMonster:GetInt() + 1)

	self:Save()

	--通知一下QuestMgr 和 AchevementMgr
	--QuestMgr:dispatchEvent({name = "KILL_MONSTER"})
	--AchevementMgr:dispatchEvent({name = "KILL_MONSTER"})

	--这里应该抛一个消息出去，谁对这个消息感兴趣，就去处理这个消息
	cclog("----MotionMgr dispatchEvent KILL_MONSTER")
	NotifyCenter:dispatchEvent({name = MotionEvents.KILL_MONSTER,args = 5})
end

return MotionMgr