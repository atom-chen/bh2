
local StageModel = class("StageModel")

StageModel.__index = StageModel

StageType = 
{
	Normal = 1,
	Challenge = 2,

}

local SceneNode=
{
	prevId = 0,
	nextId = 0,
	state = "unk",
}



local ChapterList = {}

local StageList = {}

local function InitStage()
	for i=0,table.nums(sStageStore) do
		local entry = sStageStore[i]
		if entry then
			local node = StageList[entry.id]
            if not node then
                StageList[entry.id] = clone(SceneNode)
                node = StageList[entry.id]
            end
            node.nextId = entry.nextId
            if node.nextId ~= 0 then
                local nextNode = StageList[node.nextId]
                if not nextNode then
                    StageList[node.nextId] = clone(SceneNode)
                    nextNode = StageList[node.nextId]
                end
                nextNode.prevId = entry.id
            end
		end
	end

	for k,v in pairs(StageList) do
		cclog("stage id:"..k.." prevId:"..v.prevId.." nextId:"..v.nextId)
	end	
end

function StageModel:ctor()
	self._stageData = StorageMgr:getStageDataMgr()
    self._achievementMgr = StorageMgr:getAchievementDataMgr()

	InitStage()

    --InitChapter()

    self:Init()
end

function StageModel:Init()
    self._canEnterChapter = {}
    self._allowableStages = {}
    self._chapterStar = {}

    local allowStages = self._stageData:getAllowableStages()
    for k,stageId in pairs(allowStages) do
        self:addAllowableStage(stageId,true)
    end

    local passChapters = self._stageData:getPassChapters()
    for k,chapterId in pairs(passChapters) do
        local star = self._stageData:getChapterInfo(chapterId)
        assert("ERROR:chapter pass,but has no star")
        self:addPassChapter(chapterId,star,true)
    end

    dump(self._canEnterChapter,"can enter chapter:")
    dump(self._allowableStages,"can enter stage:")
end

local function getStageType(stageId)
    local entry = sStageStore[stageId]
    assert(entry)
    return entry.type
end


function StageModel:addPassChapter(chapterId,chapterStar,bInit)
    assert(type(chapterId) == "number" and type(chapterStar) == "number")

    self._canEnterChapter[chapterId] = "pass"
    self._chapterStar[chapterId] = chapterStar
    local entry = gChapterChain[chapterId]
    if entry and getStageType(entry.stage) ~= StageType.Challenge then
        local nextId = gFirstChapterChain[entry.firstId][entry.rank+1]
        if nextId then
            if self._canEnterChapter[nextId] == nil or self._canEnterChapter[nextId] ~= "pass" then
                self._canEnterChapter[nextId] = "new"
            end
        end
    end

    if not bInit then
        self._stageData:addPassChapter(chapterId)

        --把pass章节的已提交的成就移除掉
        local entry = gChapterChain[chapterId]
        for i = 0,#gChapterChain[chapterId].achievements do
            local achievementId = gChapterChain[chapterId].achievements[i]
            assert(achievementId)
            if achievementId ~= 0 then
                local achievement = self._achievementMgr:getAchievement(achievementId)
                if achievement:isSubmit() == true then
                    self._achievementMgr:removeAchievement(achievement)
                end
            end
        end


        cclog("解锁下一个关卡的同时，把下一个关卡的成就加到achievementMgr")
        local nextId = gFirstChapterChain[entry.firstId][entry.rank+1] or 0
        if nextId ~= 0 then
            for i = 0,#gChapterChain[nextId].achievements do
                local achievementId = gChapterChain[nextId].achievements[i]
                assert(achievementId)
                if achievementId ~= 0 then
                   self._achievementMgr:addAchievement(achievementId,1)
                end
            end
        end
    end
end

function StageModel:addAllowableStage(stageId,bInit)
    self._allowableStages[#self._allowableStages + 1] = stageId

    local chapters = self:getChaptersByStageId(stageId)
    local bNew = false
    for k,chapterId in pairs(chapters) do
        if self._canEnterChapter[chapterId] == nil then
            if bNew == false then
                self._canEnterChapter[chapterId] = "new"
                bNew = true
            else
                self._canEnterChapter[chapterId] = "disable"
            end 
        elseif self._canEnterChapter[chapterId] == "new" then
            bNew = true
        end
    end

    if not bInit then
        self._stageData:addAllowableStage(stageId)
    end
end

function StageModel:hasOpenedStage(stage)
    if table.keyof(self._allowableStages,stage) then
        return true
    end
    return false
end

function StageModel:getMaxStage()
    local ret = 0

    for chapterId,state in pairs(self._canEnterChapter) do
        if state == "new" then
            local chapterNode = gChapterChain[chapterId]
            assert(chapterNode)
            ret = chapterNode.stage
            break
        end
    end

    return ret
end

function StageModel:getNewestChapter()
    local ret = 0

    for chapterId,state in pairs(self._canEnterChapter) do
        if state == "new" then
            ret = chapterId
            break
        end
    end

    return ret
end

function StageModel:getChaptersByStageId(stageId)
    local ret = {}
    for k,entry in pairs(sChapterStore) do
        if entry.stage_index == stageId then
            ret[#ret + 1] = entry.id
        end
    end
    
    return ret
end

function StageModel:getChapterStar(chapterId)
    return self._stageData:getChapterInfo(chapterId)
end

function StageModel:getStageStar(stageId)
    local ret = 0

    local chapters = self:getChaptersByStageId(stageId)
    for k,chapterId in pairs(chapters) do
        if self._canEnterChapter[chapterId] and self._canEnterChapter[chapterId] == "pass" then
            ret = ret + self:getChapterStar(chapterId)
        end
    end

    return ret
end

function StageModel:enterBattle(stageId,chapterId)
	--校验

	display.removeUnusedSpriteFrames()
	StageManager:loadfromdbc()
	GameLogic:init(stageId,chapterId)
	UIMgr:EnterScene(GameState.BATTLE)
end

return StageModel