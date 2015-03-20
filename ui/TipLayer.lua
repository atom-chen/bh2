local ViewBase = require("ui.ViewBase")
local TipLayer = class("TipLayer", ViewBase)

TipLayer.RESOURCE_FILENAME = "ui/BattleTip1.csb"
TipLayer.AUTOSCALE = true

--local heroModel = require("models.heroModel")

function TipLayer:onCreate()
	--self._heroModel = self:getParent():getModel()--heroModel.new()

	local bg = self:getPanel():getChild("Image_bg")
	bg:setTouchEnabled(true)
	bg:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.backCallback)})

	self:getPanel():getChild("img_bg_5"):setTouchEnabled(true)
	self:getPanel():getChild("btn_tubiao_1"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.upgradeHeroCallback)})
	self:getPanel():getChild("btn_tubiao_2"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.hireHeroCallback)})
	self:getPanel():getChild("btn_tubiao_3"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.shopCallback)})
	self:getPanel():getChild("img_bg_5"):getChild("btn_clouse_5"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.backCallback)})
	self:getPanel():getChild("img_bg_5"):getChild("btn_fanhui_5"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.backCallback)})
	self:getPanel():getChild("img_bg_5"):getChild("btn_queding_5"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.toFormationCallback)})
end

function TipLayer:Init()

end

function TipLayer:upgradeHeroCallback()
	local mainLayer = UIMgr:getMainLayer()

	self:getParent():removeFromParent()

	mainLayer:toHeroInfoCallback()
end

function TipLayer:hireHeroCallback()
	local mainLayer = UIMgr:getMainLayer()

	self:getParent():removeFromParent()

	mainLayer:toHeroesCallback()
end

function TipLayer:shopCallback( ... )
	local mainLayer = UIMgr:getMainLayer()

	self:getParent():removeFromParent()

	mainLayer:toShopLayer()
end

function TipLayer:toFormationCallback( ... )
	self:getParent():toFormationCallback()

	self:removeFromParent()
end

function TipLayer:backCallback(uiwidget)
	self:removeFromParent()
end

return TipLayer