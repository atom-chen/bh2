
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

local function InitChapter()
    for i = 0,table.nums(sChapterStore) do
        local entry = sChapterStore[i]
        if entry then
            local node = ChapterList[entry.id]
            if not node then
                ChapterList[entry.id] = clone(SceneNode)
                node = ChapterList[entry.id]
            end
            node.nextId = entry.nextId
            if node.nextId ~= 0 then
                local nextNode = ChapterList[node.nextId]
                if not nextNode then
                    ChapterList[node.nextId] = clone(SceneNode)
                    nextNode = ChapterList[node.nextId]
                end
                nextNode.prevId = entry.id
            end
        end
    end
end

function StageModel:ctor()
	self._stageData = require("utils.StorageMgr"):getInstance():getStageDataProxy()

	InitStage()
end

function StageModel:Init()
	
end

function StageModel:enterBattle(stageId,chapterId)
	--校验

	display.removeUnusedSpriteFrames()
	StageManager:loadfromdbc()
	GameLogic:init(stageId,chapterId)
	UIMgr:EnterScene(GameState.BATTLE)
end

return StageModel