
--local MgrBase = require("utils.manager.MgrBase")
local QuestDataMgr = class("QuestDataMgr")--, MgrBase)
local HexData = require("utils.HexData")

local __instance = nil
local __allowInstance = nil

local QuestState = 
{
	New = 1,
	Running = 2,
	Complete = 3,
	Submit = 4,
}

local QuestType = 
{
	KillMonster = 1,
	UpgradeSkill = 2,
	UpgradeEquip = 3,
	PassStage = 4,
}

--["questinfo"] = {[1] = {id,status,reqCount,curCount}}

-------------???????????????????????????????????
---------用户在每天的首次登陆会重置每日任务列表。那么如何知道用户是某一天的首次登陆
-------------??????????????????????????????????????
--英雄之战中SWorld::ResetDailyQuests()？？？？

function QuestDataMgr:ctor()
    --QuestDataMgr.super.ctor(self, "QuestDataMgr")
    --cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()


    --self:addEventListener(MotionEvents.KILL_MONSTER, handler(self,self.killMonster))
    self:Init()
end

function QuestDataMgr:getInstance( )
	if not __instance then
		__allowInstance = true
		__instance = QuestDataMgr.new()
		__allowInstance = false
	end

	return __instance
end

function QuestDataMgr:setMgr(mgr)
	self._mgr = mgr
end

function QuestDataMgr:getMgr()
	assert(self._mgr,"Error:QuestDataMgr should have a mgr")
	return self._mgr
end

function QuestDataMgr:Init(data)

	self._questInfo = {}
	--id,state,process(进度)
	if not data then return false end
	for questId,v in pairs(data) do
		self._questInfo[questId] = QuestState.New
	end

	return true
end

function QuestDataMgr:Reset()
	-- body
end

function QuestDataMgr:Load(jsonValue)
	cclog("----------QuestDataMgr:Load")

	if DailyFirstLogin then
		cclog("重置每日任务")
		self:ResetDailyQuest()
	else
		--questId,state,process
		self._questInfo = jsonValue["questinfo"]--HexData.new((jsonValue["questInfo"]) or "")
		--self._undoneQuests = string.split(questInfo,",")
		--dump(self._questInfo)
	end
end

function QuestDataMgr:ResetDailyQuest()
	for k,entry in pairs(sQuestInfo) do
		self._questInfo[#self._questInfo + 1] = { id = entry.id,status = QuestState.New, reqCount = entry.reqCount,curCount = 0 }
	end
end

function QuestDataMgr:GetAllQuests()
	return self._questInfo or {}
end

function QuestDataMgr:GetQuestInfoByType(_type)
	local ret = {}
	for questId,state in pairs(self._questInfo) do
		if state ~= QuestState.Complete then
			if sQuestInfo[questId].type == _type then
				ret[#ret + 1] = sQuestInfo[questId]
			end
		end
	end

	return ret
end

function QuestDataMgr:killMonster(t)
	--杀所有的怪都会进此函数，但如果要杀特定的怪物呢。。。(每日任务还杀什么指定的怪物，每日任务做的都是普遍的事情)
	cclog("QuestDataMgr KILL_MONSTER func...")
	local questInfos = self:GetQuestInfoByType(QuestType.KillMonster)
	for i = 1,#questInfos do

	end
end

function QuestDataMgr:RewardQuest(questId)
	local function CheckQuest(questId)
		if not sQuestInfo[questId] then
			assert(false,"任务表找不到对应的questId"..questId)
			return false
		end

		if not self._questInfo[questId] then
			assert(false,"每日任务中找不到此任务Id:"..questId)
			return false
		end

		return true
	end

	if CheckQuest(questId) then
		--self:dispatchEvent({name = "FINISH_QUEST",questId = questId})
		for k,v in pairs(self._questInfo) do
			if v.Id == questId and v.status == QuestState.Complete then

				break
			end
		end
	end

	--任务奖励，移除此任务
end

return QuestDataMgr