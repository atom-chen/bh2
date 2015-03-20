local ViewBase = require("ui.ViewBase")
local QuestLayer = class("QuestLayer", ViewBase)

QuestLayer.RESOURCE_FILENAME = "ui/Task_1.csb"
QuestLayer.AUTOSCALE = true

--local stageModel = require("models.StageModel")

function QuestLayer:onCreate()
	self:getPanel():getChild("btn_close"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.backMainCallback)})

	self:getPanel():getChild("Image_18"):setVisible(false)
	self:getPanel():getChild("Image_19"):setVisible(false)

	self._list = self:getPanel():getChild("ListView")
	for i = 1,5 do
		local layout = ccui.Layout:create()
		local item = cc.CSLoader:createNode("ui/TaskItem.csb")
		item:setTag(i)
		layout:addChild(item)
		layout:setSize(item:getChild("bg_1"):getSize())
		self._list:addChild(layout)
	end
	--self._list:setItemsMargin(-10.0)
	--self._list:doLayout()
end

function QuestLayer:backMainCallback(uiwidget)
	self:removeFromParent()
end

return QuestLayer