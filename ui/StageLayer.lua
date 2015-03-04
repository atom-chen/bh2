local ViewBase = require("ui.ViewBase")
local StageLayer = class("StageLayer", ViewBase)

StageLayer.RESOURCE_FILENAME = "ui2/TollgateView_1.csb"
StageLayer.AUTOSCALE = true

local stageModel = require("models.StageModel")

function StageLayer:onCreate()
	--local action = cc.CSLoader:createTimeline("ui2/TownView_1.csb")
    --action:gotoFrameAndPlay(0,true)
    --self:runAction(action)

	self._model = stageModel.new()

	self:addNodesEventListener()
end

function StageLayer:addNodesEventListener()
	self:getPanel():getChild("tollgate_btn_battle"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.enterBattleCallback)})
	
end

function StageLayer:enterBattleCallback(uiwidget)
	local stageId,chapterId = 1,1
	self._model:enterBattle(stageId,chapterId)
end

return StageLayer