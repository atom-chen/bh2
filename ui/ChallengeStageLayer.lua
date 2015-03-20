local ViewBase = require("ui.ViewBase")
local ChallengeStageLayer = class("ChallengeStageLayer", ViewBase)

ChallengeStageLayer.RESOURCE_FILENAME = "ui/TollgateView_8.csb"
ChallengeStageLayer.AUTOSCALE = true

local stageId = 30

local function getChaptersByStageId(stageId)
    local chapterList = {}
    for k,entry in pairs(sChapterStore) do
        if entry.stage_index == stageId then
            chapterList[#chapterList + 1] = entry.id
        end
    end
    
    return chapterList
end

function ChallengeStageLayer:onCreate()

	local btn = self:getPanel():getChild("btn_back")
	btn:setTouchEnabled(true)
	btn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.backCallback)})

end

function ChallengeStageLayer:Init()
	self._model = self:getParent():getModel()

	local chapters = getChaptersByStageId(30)
	for i = 1,#chapters do
		local chapterId = chapters[i]
		local entry = gChapterChain[chapterId]
		assert(entry)
		local btn = self:getPanel():getChild("btn_yincan_"..i-1)
		--btn:getChild("starnum_"..i-1):setString(self._model:getStageStar(entry.reqStageId))
		--btn:getChild("allnum"..i-1):setString(entry.reqStageStar)
		if self._model:getStageStar(entry.reqStageId) >= entry.reqStageStar then
			btn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.battleCallback)})
		end
	end
end

function ChallengeStageLayer:battleCallback()
	cclog("--battle")
end

function ChallengeStageLayer:backCallback()
	self:removeFromParent()
end


return ChallengeStageLayer