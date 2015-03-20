
local AchievementModel = class("AchievementModel")

AchievementModel.__index = AchievementModel

function AchievementModel:ctor()
	self._achievementMgr = StorageMgr:getAchievementDataMgr()
	self._teamData = StorageMgr:getTeamDataMgr()
	self._bag = StorageMgr:getBagDataMgr()
end

function AchievementModel:getAchievementByIdx(idx)
	return self._achievementMgr:getAchievementByIdx(idx)
end

function AchievementModel:getAchievement(id)
	return self._achievementMgr:getAchievement(id)
end

function AchievementModel:finishAchievement(id)
	local achievement = self._achievementMgr:getAchievement(id)
	if achievement:isDone() == false then
		return errorCode.ACHIEVEMENT_NOT_DONE
	end

	if achievement:isSubmit() == true then
		return errorCode.ACHIEVEMENT_HAS_BEEN_SUBMITED
	end

	assert(self._achievementMgr:submitAchievement(achievement))

	local entry = achievement:getEntry()
	assert(entry,"nil entry")
	self._teamData:modifyCoin(entry.rewardCoin)
	for i = 0,#entry.rewardItem do
		local itemId = entry.rewardItem[i]
		if itemId ~= 0 then
			self._bag:LootItem(itemId)
		end
	end

	StorageMgr:Save()

	return 0
end

return AchievementModel