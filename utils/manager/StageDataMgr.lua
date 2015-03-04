local StageDataMgr = class("StageDataMgr")

local __instance = nil
local __allowInstance = nil

--关卡信息：（关卡类型，开通的关卡StageId，通过的ChapterId,SectionId）

--表现：普通关卡要知道总共有多少个Stage，每个stage有多少个章节 --(交给model)

local HexData = require("utils.HexData")

function StageDataMgr:ctor()
    --StageDataMgr.super.ctor(self, "StageDataMgr")
    if not __allowInstance then
		error("StageDataMgr is a singleton")
	end
end

function StageDataMgr:getInstance( )
	if not __instance then
		__allowInstance = true
		__instance = StageDataMgr.new()
		__allowInstance = false
	end

	return __instance
end

function StageDataMgr:setMgr(mgr)
	self._mgr = mgr
end

function StageDataMgr:getMgr()
	assert(self._mgr,"Error:StageDataMgr should have a mgr")
	return self._mgr
end

function StageDataMgr:Load(jsonValue)
	cclog("----------StageDataMgr:Load")
	local passStages = HexData.new((jsonValue["passStages"]) or "")
	self._passStages = string.split(passStages,",")
	local passChapters = HexData.new((jsonValue["passChapters"]) or "")
	self._passChapters = string.split(passChapters,",")
	--self._passStages = HexData.new((jsonValue["passStages"]) or "")
	--self._passChapters = HexData.new(jsonValue["passChapters"] or "")

end

function StageDataMgr:Save()
	assert(self._mgr,"Error:StageDataMgr should have a mgr")
	self._mgr:Save()
end

function StageDataMgr:addPassChapter(chapterId)
	if table.keyof(self._passChapters,chapterId) then
		return false
	end

	self._passChapters[#self._passChapters + 1] = chapterId
end

function StageDataMgr:AddAllowable(stageId)
	if table.keyof(self._passStages,stageId) then
		return false
	end

	self._passStages[#self._passStages + 1] = stageId
end


return StageDataMgr

--[[
local SceneNode=
{
	prevId = 0,
	nextId = 0,
	state = "unk",
}

local SceneList = {}
StageDataMgr.stages = {}

function StageDataMgr:getScenesByStageId( stageId )
	local scenes = {}
	local entry = getSceneEntry(sPlayer.stage_id)
	local nextSceneId = entry.nextId
	for i = 0,getSceneStoreNums() do
		local entry = getSceneEntry(i)
		if entry and entry.group == stageId then
			scenes[#scenes + 1] = entry.id
		end
	end
	return scenes
end

function StageDataMgr:getSceneList( stageId )
	self:initScene()
	self:setPassed(SceneList[sPlayer.stage_id].prevId)
	local allScene,scenes = {},{}
	for k,v in pairs(SceneList) do
    	if v.state == "passed" then
    		allScene[#allScene + 1] = k
    	end
        --cclog("Scene id:"..k.." prevId:"..v.prevId.." nextId:"..v.nextId.." state:"..v.state)
    end

    allScene[#allScene + 1] = sPlayer.stage_id

    for i = 1,#allScene do
		local entry = getSceneEntry(allScene[i])
		if entry and entry.group == stageId then
			scenes[#scenes + 1] = entry.id
		end
	end

	return scenes
end

function StageDataMgr:initStage()
	for i=0,#sSceneGroupStores do
		local entry = sSceneGroupStores[i]
		if entry then
			local node = self.stages[entry.id]
            if not node then
                self.stages[entry.id] = clone(SceneNode)
                node = self.stages[entry.id]
            end
            node.nextId = entry.nextId
            if node.nextId ~= 0 then
                local nextNode = self.stages[node.nextId]
                if not nextNode then
                    self.stages[node.nextId] = clone(SceneNode)
                    nextNode = self.stages[node.nextId]
                end
                nextNode.prevId = entry.id
            end
		end
	end

	for k,v in pairs(self.stages) do
		cclog("stage id:"..k.." prevId:"..v.prevId.." nextId:"..v.nextId)
	end	
end

function StageDataMgr:initScene()
    for i = 0,getSceneStoreNums() do
        local entry = getSceneEntry(i)
        if entry then
            local node = SceneList[entry.id]
            if not node then
                SceneList[entry.id] = clone(SceneNode)
                node = SceneList[entry.id]
            end
            node.nextId = entry.nextId
            if node.nextId ~= 0 then
                local nextNode = SceneList[node.nextId]
                if not nextNode then
                    SceneList[node.nextId] = clone(SceneNode)
                    nextNode = SceneList[node.nextId]
                end
                nextNode.prevId = entry.id
            end
        end
    end
end

function StageDataMgr:setPassed(id)
    if SceneList[id] then
        SceneList[id].state = "passed"
        self:setPassed(SceneList[id].prevId)
    end
end

function StageDataMgr:GetNewestStageId()
	local stageId = 0

	local sceneEntry = getSceneEntry(sPlayer.stage_id)
	if sceneEntry then
		stageId = sceneEntry.group 
	else
		assert(false,"cur sceneEntry nil")
	end
	
	
	return stageId
end

function StageDataMgr:GetPassedGroup()
	local newestGroup = self:GetNeweststageId()
	local stages = {}
	local function setPassed(id)
		if self.stages[id] then
			self.stages[id].state = "passed"
			stages[#stages+1] = id
			setPassed(self.stages[id].prevId)
			cclog("passed group : "..id.." prevId :"..self.stages[id].prevId)
		end
	end
	setPassed(self.stages[newestGroup].prevId)
	return stages
end

function StageDataMgr:isLastSceneInGroup( sceneId ) --是否一个大关中的最后一关
	local sceneEntry = getSceneEntry(sceneId)
	assert(sceneEntry,"cur sceneEntry nil")
	if sceneEntry.group >= 100 then
		--group>100说明是活动副本,活动副本不参与评分
		return false
	end

	local nextId = sceneEntry.nextId
	local nextSceneEntry = getSceneEntry(nextId)
	if nextSceneEntry then
		if nextSceneEntry.group == sceneEntry.group then
			return false
		else
			return true
		end
	else
		--
		return true
	end

end]]