local ViewBase = require("ui.ViewBase")
local ChallengeChapterLayer = class("ChallengeChapterLayer", ViewBase)

ChallengeChapterLayer.RESOURCE_FILENAME = "ui/BattleTip1.csb"
ChallengeChapterLayer.AUTOSCALE = true

function ChallengeChapterLayer:onCreate()
	--self._heroModel = self:getParent():getModel()--heroModel.new()

	local btn = self:getPanel():getChild("btn_back")
	btn:setTouchEnabled(true)
	btn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.backCallback)})
end

function ChallengeChapterLayer:Init(chapterId)
	local entry = gChapterChain[chapterId]
end

function ChallengeChapterLayer:battleCallback()
	cclog("--battle")
end

function ChallengeChapterLayer:backCallback()
	self:removeFromParent()
end


return ChallengeChapterLayer