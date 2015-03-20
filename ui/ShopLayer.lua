local ViewBase = require("ui.ViewBase")
local ShopLayer = class("ShopLayer", ViewBase)

ShopLayer.RESOURCE_FILENAME = "ui/Shop.csb"
ShopLayer.AUTOSCALE = true

ShopTag = 
{
	HotSale = 1,
	AssistIntensify = 2,
	CoinConsume =3
}

--local stageModel = require("models.StageModel")

function ShopLayer:onCreate()
	self:getPanel():getChild("shop_btn_back"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.backMainCallback)})
	self:getPanel():getChild("btn_gold"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.btnCallback)})
	self._shopType = ShopTag.CoinConsume
end

function ShopLayer:switchToLayer(tag)
	self:btnCallback(tag)
end

function ShopLayer:backMainCallback(uiwidget)
	self:removeFromParent()
end

function ShopLayer:btnCallback(widgetOrTag)
	if tolua.type(widgetOrTag) ~= "number" then
		widgetOrTag = widgetOrTag:getTag()
	end

	if widgetOrTag == ShopTag.HotSale then

	elseif widgetOrTag == ShopTag.AssistIntensify then

	elseif widgetOrTag == ShopTag.CoinConsume then

	end
end

function ShopLayer:buyItemCallback(uiwidget)
	--调用sdk接口去购买商品
	
end

function ShopLayer:UpdateView()
	
end

return ShopLayer