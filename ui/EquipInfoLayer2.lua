local ViewBase = require("ui.ViewBase")
local EquipInfoLayer2 = class("EquipInfoLayer2", ViewBase)

EquipInfoLayer2.RESOURCE_FILENAME = "ui/EquipInfo2.csb"
EquipInfoLayer2.AUTOSCALE = true

--local heroModel = require("models.heroModel")

function EquipInfoLayer2:onCreate()
	--self._heroModel = self:getParent():getModel()--heroModel.new()

	local bg = self:getPanel():getChild("Image_bg")
	bg:setTouchEnabled(true)
	bg:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.backCallback)})

	self._panel = self:getPanel():getChild("Panel1")
	
	--self:getPanel():getChild("Image_boardBg"):setTouchEnabled(true)
end

function EquipInfoLayer2:Init(item)
	self._heroModel = self:getParent():getModel()

	self._selectHero = self:getParent():getModel():getSelectHero()
	self._item = item
	assert(self._item)

	self._panel:getChild("Button_unequip"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.unequipCallback)})
	self._panel:getChild("Button_forge"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.forgeCallback)})
	self._panel:getChild("Button_sell"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.sellCallback)})

	self._panel:getChild("Image_equipIcon"):loadTexture(item:getDisplay())
	self._panel:getChild("Text_equipname"):setString(item:getName())
	--self._panel:getChild("Image_quality"):loadTexture(self._item:getQualityDisplay())
	self._panel:getChild("Text_defence"):setString(tostring(item:getDefence()))
	self._panel:getChild("Text_hp"):setString(tostring(item:getHp()))
	self._panel:getChild("Text_atk"):setString(tostring(item:getAttack()))
	self._panel:getChild("Text_lv"):setString(tostring(item:getReqLevel()))

	local randomStats = item:getRandomStats()
	for i = 1,#randomStats do
		local wordEntry = sItemRandomWordStore[randomStats[i]]
		self._panel:getChild("Text_prop"..i .. "_desc"):setVisible(true)
		self._panel:getChild("Text_prop"..i .. "_desc"):setString(wordEntry.desc)
		self._panel:getChild("Text_prop_value"..i):setVisible(true)
		self._panel:getChild("Text_prop_value"..i):setString("+"..tostring(wordEntry.word_value))
	end

	for i = #randomStats + 1,5 do
		self._panel:getChild("Text_prop"..i .. "_desc"):setVisible(false)
		self._panel:getChild("Text_prop_value"..i):setVisible(false)
	end

	if item:getQuality() == Quality.E then
		self._panel:getChild("Button_forge"):setVisible(false)
		self._panel:getChild("Button_forge"):setTouchEnabled(false)
		self._panel:getChild("num_forgecost"):setVisible(false)
	end

end

function EquipInfoLayer2:equipCallback()
	cclog(".....装备")

	local opRet = self._heroModel:equipItem(self._item)
	if opRet == 0 then
		self:removeFromParent()
	else
		cclog("装备不成功,error："..opRet)
	end
end

function EquipInfoLayer2:unequipCallback()
	cclog(".....脱装备")

	local opRet = self._heroModel:unEquipItem(self._item)
	if opRet == 0 then
		self:removeFromParent()
	else
		cclog("脱装备不成功,error："..opRet)
	end
end

function EquipInfoLayer2:forgeCallback()
	cclog(".....强化")

	local opRet = self._heroModel:forgeItem(self._item)
	if opRet == 0 then
		cclog("强化物品成功")
		self:Update()
	else
		cclog("强化失败，error:"..opRet)
	end
end

function EquipInfoLayer2:sellCallback()
	cclog(".....售出")

	local opRet = self._heroModel:sellItem(self._item)
	if opRet == 0 then
		cclog("售出物品成功！！！")
		self:removeFromParent()
	else
		cclog("售出失败，error:"..opRet)
	end
end

function EquipInfoLayer2:Update()
	local randomStats = self._item:getRandomStats()

	for i = 1,#randomStats do
		local wordEntry = sItemRandomWordStore[randomStats[i]]
		self._panel:getChild("Text_prop"..i .. "_desc"):setVisible(true)
		self._panel:getChild("Text_prop"..i .. "_desc"):setString(wordEntry.desc)
		self._panel:getChild("Text_prop_value"..i):setVisible(true)
		self._panel:getChild("Text_prop_value"..i):setString("+"..tostring(wordEntry.word_value))
	end

	for i = #randomStats + 1,5 do
		self._panel:getChild("Text_prop"..i .. "_desc"):setVisible(false)
		self._panel:getChild("Text_prop_value"..i):setVisible(false)
	end
end

function EquipInfoLayer2:backCallback(uiwidget)
	self:removeFromParent()
end

return EquipInfoLayer2