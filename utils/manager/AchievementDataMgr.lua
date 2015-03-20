
local AchievementDataMgr = class("AchievementDataMgr")--, MgrBase)
local Achievement = require("utils.Achievement")

local __instance = nil
local __allowInstance = nil

AchievementType = 
{
	KillMonster = 1,
	PassChapter = 2,
	UpgradeSpell = 3,
	ForgeEquip = 4,
	
}

function AchievementDataMgr:ctor()
    self:Init()
end

function AchievementDataMgr:getInstance( )
	if not __instance then
		__allowInstance = true
		__instance = AchievementDataMgr.new()
		__allowInstance = false
	end

	return __instance
end

function AchievementDataMgr:setMgr(mgr)
	self._mgr = mgr
end

function AchievementDataMgr:getMgr()
	assert(self._mgr,"Error:AchievementDataMgr should have a mgr")
	return self._mgr
end

function AchievementDataMgr:registerNotifyCenterEvent()
	cclog("------AchievementDataMgr:registerNotifyCenterEvent()")
	NotifyCenter:addEventListener(Events.UPGRADE_SPELL, handler(self,self.upgradeSpell))
	NotifyCenter:addEventListener(Events.KILL_MONSTER, handler(self,self.killMonster))
	NotifyCenter:addEventListener(Events.FORGE_EQUIP,handler(self,self.forgeEquip))
end

function AchievementDataMgr:unregisterNotifyCenterEvent()
	NotifyCenter:removeEventListenersByEvent(Events.UPGRADE_SPELL)
	NotifyCenter:removeEventListenersByEvent(Events.KILL_MONSTER)
	NotifyCenter:removeEventListenersByEvent(Events.FORGE_EQUIP)
end

function AchievementDataMgr:Init(data)
	self._achievements = {}
	self:registerNotifyCenterEvent()
end

function AchievementDataMgr:Reset()
	self._achievements = {}
	--self:unregisterNotifyCenterEvent()
	--self:registerNotifyCenterEvent()
end

function AchievementDataMgr:Save()
	assert(self._mgr,"Error:AchievementDataMgr should have a mgr")
	self._mgr:Save()
end

function AchievementDataMgr:Load(jsonValue)
	local temp = jsonValue or {}
    for i = 1,#temp do
    	local achievement = Achievement.new()
		achievement:Load(temp[i])
    	self._achievements[#self._achievements + 1] = achievement
    end
end

function AchievementDataMgr:GetData()
	local ret = {}
	for i = 1,#self._achievements do
		ret[i] = self._achievements[i]:GetData()
	end
	--记录的应该是最后一个正在进行的成就

	return ret
end


function AchievementDataMgr:addAchievement(id,idx)
	assert(type(id) == "number" and id ~= 0)
	local achievement = Achievement.new()
	achievement:Create(id)
	if idx then
		table.insert(self._achievements,idx,achievement)
	else
		table.insert(self._achievements,achievement)
	end
end

function AchievementDataMgr:removeAchievement(achievement)
	assert(achievement:isDone(),"achievement not done yet!!")

	local removecount = table.removebyvalue(self._achievements,achievement,true)
	if removecount > 0 then
		cclog("移除成功,移除后成就个数"..table.nums(self._achievements))
		return true
	end
	assert(false,"移除成就失败")
	return false
end

function AchievementDataMgr:submitAchievement(achievement)
	assert(achievement:isDone(),"achievement not done yet!!")

	achievement:setState(AchievementState.Submit)

	local entry = achievement:getEntry()
	local firstId = entry.firstId
	local rank = entry.rank
	assert(entry)
	local nextId = gFirstAchievementChain[firstId][rank + 1] or 0
	if nextId ~= 0 then
		self:addAchievement(nextId)
		self:removeAchievement(achievement)
	else
		cclog("此成就没有后续的成就")	
	end

	return true
end

function AchievementDataMgr:getAchieventments()
	return self._achievements
end

function AchievementDataMgr:getAchievementByIdx(idx)
	assert(type(idx) == "number","ERROR:Invalid param")
	return self._achievements[idx]
end

function AchievementDataMgr:getAchievement(id)
	for k,v in pairs(self._achievements) do
		if v:getId() == id then 
			return v
		end
	end
	return nil
end

function AchievementDataMgr:upgradeSpell()
	cclog("成就：技能升级，进度加1。。。。。")
	for k,achievement in pairs(self._achievements) do
		if achievement:getType() == AchievementType.UpgradeSpell then
			achievement:modifyCurrentProgress(1)
		end
	end

	self:Save()
end

local function getMonsterType(monsterId)
	return 0
end

function AchievementDataMgr:killMonster(t)
	monsterId = t.monsterId or 0
	chapterId = t.chapterId or 0
	cclog(chapterId .."章杀死怪物("..monsterId.."),触发成就")
	for k,achievement in pairs(self._achievements) do
		local reqChapterId = achievement:getReqChapterId()
		if reqChapterId == 0 or reqChapterId == chapterId then
			if achievement:getType() == AchievementType.KillMonster then
				if achievement:getSubType() == 0 then
					achievement:modifyCurrentProgress(1)
				elseif achievement:getSubType() == getMonsterType(monsterId) then
					achievement:modifyCurrentProgress(1)
				end
			end
		end
	end

	self:Save()
end

return AchievementDataMgr