local ViewBase = require("ui.ViewBase")
local BattleFailLayer = class("BattleFailLayer", ViewBase)

BattleFailLayer.RESOURCE_FILENAME = "ui/BattleFail.csb"
BattleFailLayer.AUTOSCALE = true

--local heroModel = require("models.heroModel")

function BattleFailLayer:onCreate()
	--self._heroModel = self:getParent():getModel()--heroModel.new()

	local bg = self:getPanel():getChild("Image_bg")
	bg:setTouchEnabled(true)
	bg:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.backCallback)})

	self:getPanel():getChild("battle_end_btn_return2"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.replayCallback)})
	self:getPanel():getChild("battle_end_btn_town_1"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.toHeroCallback)})

	self:getPanel():getChild("btn_tubiao_1"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.upgradeHeroCallback)})
	self:getPanel():getChild("btn_tubiao_2"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.hireHeroCallback)})
	self:getPanel():getChild("btn_tubiao_3"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.shopCallback)})
end

function BattleFailLayer:Init()

end

function BattleFailLayer:replayCallback( )
	-- body
end

function BattleFailLayer:toHeroCallback( )
	UIMgr:EnterScene(GameState.MAIN)
	local mainLayer = UIMgr:getMainLayer()
	if mainLayer then
		mainLayer:toHeroInfoCallback()
	end
end

function BattleFailLayer:upgradeHeroCallback()
	local mainLayer = UIMgr:getMainLayer()

	self:getParent():removeFromParent()

	mainLayer:toHeroInfoCallback()
end

function BattleFailLayer:hireHeroCallback()
	local mainLayer = UIMgr:getMainLayer()

	self:getParent():removeFromParent()

	mainLayer:toHeroesCallback()
end

function BattleFailLayer:shopCallback( ... )
	local mainLayer = UIMgr:getMainLayer()

	self:getParent():removeFromParent()

	mainLayer:toShopLayer()
end

function BattleFailLayer:backCallback(uiwidget)
	self:removeFromParent()
end

return BattleFailLayer