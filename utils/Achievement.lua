local Achievement = class("Achievement")
Achievement.__index = Achievement

--["questinfo"] = {[1] = {id,status,reqCount,curCount}}

AchievementState = 
{
	unSubmit = 0,
	Submit = 1,
}

function Achievement:ctor()

end

function Achievement:Load(t)
	self._id = t.id
	self._entry = sAchievementStore[self._id]
	self._curProgress = t.curProgress 
	self._state = t.state
end

function Achievement:GetData()
	local ret = {}

	ret["id"] = self._id
	ret["curProgress"] = self._curProgress
	ret["state"] = self._state

	return ret
end

function Achievement:Create(id)
	assert(id,"ERROR: Nil AchievementId")
	self._id = id
	self._entry = gAchievementChain[id]
	self._curProgress = 0
	self._state = 0
end

function Achievement:getId()
	return self._id
end

function Achievement:getEntry()
	return self._entry
end

function Achievement:getName()
	return self._entry.name
end

function Achievement:getDesc()
	return self._entry.desc
end

function Achievement:getRewardDesc()
	return self._entry.rewardDesc
end

function Achievement:getReqChapterId()
	return self._entry.chapterId or 0
end

function Achievement:getReqCount()
	return self._entry.reqCount
end

function Achievement:getCurrentProgress()
	return self._curProgress
end

function Achievement:getType()
	return self._entry.type
end

function Achievement:getSubType()
	return self._entry.subType
end

function Achievement:modifyCurrentProgress(m)
	if m < 0 then return end
	local temp = self._curProgress + m
	--[[
	if temp > self._entry.reqCount then
		temp = self._entry.reqCount
	end]]
	self._curProgress = temp
end

function Achievement:isDone()
	if self._entry.reqCount <= self._curProgress then
		return true 
	end
	return false
end

function Achievement:getState()
	return self._state
end

function Achievement:setState(s)
	assert(type(s) == "number","ERROR:Wrong type")
	self._state = s
end

function Achievement:isSubmit()
	return self._state == AchievementState.Submit
end

function Achievement:getNextAchievementId()
	return self._entry.nextId
end

return Achievement