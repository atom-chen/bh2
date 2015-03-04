--[[
local MainLayer = class("MainLayer",
	function()
		local layer = ccui.loadWidget("ui2/TownView_1.csb")
		return layer
	end
)
MainLayer.__index = MainLayer]]
local ViewBase = require("ui.ViewBase")
local MainLayer = class("MainLayer", ViewBase)

MainLayer.RESOURCE_FILENAME = "ui2/TownView_1.csb"
MainLayer.AUTOSCALE = true

local mainModel = require("models.MainModel")

--[[
function MainLayer:ctor()

	local action = cc.CSLoader:createTimeline("ui2/TownView_1.csb")
    action:gotoFrameAndPlay(0,true)
    self:runAction(action)

	self:AutoScale()

	self._model = mainModel.new()

	self:addNodesEventListener()
end]]

function MainLayer:onCreate()
	local action = cc.CSLoader:createTimeline("ui2/TownView_1.csb")
    action:gotoFrameAndPlay(0,true)
    self:runAction(action)

	--self:AutoScale()

	self._model = mainModel.new()

	self:addNodesEventListener()
end

function MainLayer:addNodesEventListener()
	self:getPanel():getChild("btn_ballet"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.toStageCallback)})
	self:getPanel():getChild("btn_back"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.toStorageCallback)})

end
--[[
function MainLayer:AutoScale()
    for i = 1,self:getChildrenCount() do
        local child = self:getChildren()[i]
        if child:getName() ~= "Image_bg" then
        	child:pos(display.p(child:pos()))
        else
        	display:AutoScale(child)
        end
    end
end]]

function MainLayer:AddCoinCallback( uiwidget )
	--self._model:
end

function MainLayer:toStageCallback(uiwidget)
	--[[
	display.removeUnusedSpriteFrames()
	StageManager:loadfromdbc()
	GameLogic:init()
	UIMgr:EnterScene(GameState.BATTLE)]]
	local stage = require("ui.StageLayer").new()
	self:addChild(stage)
end

function MainLayer:toStorageCallback(uiwidget)
	self._model:backToStorage()

	UIMgr:EnterScene(GameState.STORAGE)
end

return MainLayer