local ViewBase = require("ui.ViewBase")
local EquipInfoLayer = class("EquipInfoLayer", ViewBase)

EquipInfoLayer.RESOURCE_FILENAME = "ui/EquipInfo1.csb"
EquipInfoLayer.AUTOSCALE = true

--local heroModel = require("models.heroModel")

function EquipInfoLayer:onCreate()
	--self._heroModel = self:getParent():getModel()--heroModel.new()

	local bg = self:getPanel():getChild("Image_bg")
	bg:setTouchEnabled(true)
	bg:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.backCallback)})

	self._bagItemPanel = self:getPanel():getChild("Panel_right")
	self._heroItemPanel = self:getPanel():getChild("Panel_left")

	self._bagItemPanel:setVisible(false)
	self._heroItemPanel:setVisible(false)
	
	--self:getPanel():getChild("Image_boardBg"):setTouchEnabled(true)
end

function EquipInfoLayer:Init(item)
	self._heroModel = self:getParent():getModel()

	self._selectHero = self:getParent():getModel():getSelectHero()
	self._item = item
	assert(self._item)

	local bShowLeft,bShowRight = false,false
	if self._heroModel:hasItemInEquipSlot(item) then
		--点击的是装备槽的物品
		bShowLeft = true
	else
		--点击的是背包的物品
		local slot = item:getSlot()
		if self._selectHero:getEquip(slot) ~= nil then
			bShowLeft = true
		end

		bShowRight = true
	end

	if bShowLeft then
		self:getPanel():getChild("Panel_left"):setVisible(true)
		self:showLeftBoard()
	end

	if bShowRight then
		self:getPanel():getChild("Panel_right"):setVisible(true)
		self:showRightBoard()
	end
end

function EquipInfoLayer:showLeftBoard()
	local slot = self._item:getSlot()
	local item = self._selectHero:getEquip(slot)
	assert(item,"nil item")

	self._heroItemPanel:getChild("Image_equipIcon"):loadTexture(item:getDisplay())
	self._heroItemPanel:getChild("Text_equipname"):setString(item:getName())
	--self._bagItemPanel:getChild("Image_quality"):loadTexture(self._item:getQualityDisplay())
	self._heroItemPanel:getChild("Text_defence"):setString(tostring(item:getDefence()))
	self._heroItemPanel:getChild("Text_hp"):setString(tostring(item:getHp()))
	self._heroItemPanel:getChild("Text_atk"):setString(tostring(item:getAttack()))
	self._heroItemPanel:getChild("Text_lv"):setString(tostring(item:getReqLevel()))

	local randomStats = item:getRandomStats()
	for i = 1,#randomStats do
		local wordEntry = sItemRandomWordStore[randomStats[i]]
		self._heroItemPanel:getChild("Text_prop"..i .. "_desc"):setVisible(true)
		self._heroItemPanel:getChild("Text_prop"..i .. "_desc"):setString(wordEntry.desc)
		self._heroItemPanel:getChild("Text_prop_value"..i):setVisible(true)
		self._heroItemPanel:getChild("Text_prop_value"..i):setString("+"..tostring(wordEntry.word_value))
	end

	for i = #randomStats + 1,5 do
		self._heroItemPanel:getChild("Text_prop"..i .. "_desc"):setVisible(false)
		self._heroItemPanel:getChild("Text_prop_value"..i):setVisible(false)
	end
end

function EquipInfoLayer:showRightBoard()
	self._bagItemPanel:getChild("Button_verify"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.vetifyCallback)})
	self._bagItemPanel:getChild("Button_equip"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.equipCallback)})
	self._bagItemPanel:getChild("Button_forge"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.forgeCallback)})
	self._bagItemPanel:getChild("Button_sell"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.sellCallback)})


	self._bagItemPanel:getChild("Image_equipIcon"):loadTexture(self._item:getDisplay())
	self._bagItemPanel:getChild("Text_equipname"):setString(self._item:getName())
	--self._bagItemPanel:getChild("Image_quality"):loadTexture(self._item:getQualityDisplay())
	self._bagItemPanel:getChild("Text_defence"):setString(tostring(self._item:getDefence()))
	self._bagItemPanel:getChild("Text_hp"):setString(tostring(self._item:getHp()))
	self._bagItemPanel:getChild("Text_atk"):setString(tostring(self._item:getAttack()))
	self._bagItemPanel:getChild("Text_lv"):setString(tostring(self._item:getReqLevel()))
	self._bagItemPanel:getChild("num_sell"):setString(tostring(self._item:getSellPrice()))
	if self._item:isVerify() == true then
		self._bagItemPanel:getChild("Button_verify"):setVisible(false)
		self._bagItemPanel:getChild("Button_verify"):setTouchEnable(false)
		self._bagItemPanel:getChild("num_verifycost"):setVisible(false)
		self._bagItemPanel:getChild("Button_forge"):setVisible(true)
		self._bagItemPanel:getChild("Button_forge"):setTouchEnabled(true)
		self._bagItemPanel:getChild("num_forgecost"):setVisible(true)
		self._bagItemPanel:getChild("num_forgecost"):setString(tostring(self._item:getForgePrice()))
	else
		self._bagItemPanel:getChild("Button_equip"):setVisible(false)
		self._bagItemPanel:getChild("Button_equip"):setTouchEnabled(false)
		self._bagItemPanel:getChild("Button_forge"):setVisible(false)
		self._bagItemPanel:getChild("Button_forge"):setTouchEnabled(false)
		self._bagItemPanel:getChild("num_forgecost"):setVisible(false)
		self._bagItemPanel:getChild("Button_verify"):setVisible(true)
		self._bagItemPanel:getChild("Button_verify"):setTouchEnable(true)
		self._bagItemPanel:getChild("num_verifycost"):setVisible(true)
		self._bagItemPanel:getChild("num_verifycost"):setString(tostring(self._item:getVerifyPrice()))
	end

	local randomStats = self._item:getRandomStats()
	for i = 1,#randomStats do
		local wordEntry = sItemRandomWordStore[randomStats[i]]
		self._bagItemPanel:getChild("Text_prop"..i .. "_desc"):setVisible(true)
		self._bagItemPanel:getChild("Text_prop"..i .. "_desc"):setString(wordEntry.desc)
		self._bagItemPanel:getChild("Text_prop_value"..i):setVisible(true)
		self._bagItemPanel:getChild("Text_prop_value"..i):setString("+"..tostring(wordEntry.word_value))
	end

	for i = #randomStats + 1,5 do
		self._bagItemPanel:getChild("Text_prop"..i .. "_desc"):setVisible(false)
		self._bagItemPanel:getChild("Text_prop_value"..i):setVisible(false)
	end

	if self._item:getQuality() == Quality.E then
		self._bagItemPanel:getChild("Button_forge"):setVisible(false)
		self._bagItemPanel:getChild("Button_forge"):setTouchEnabled(false)
		self._bagItemPanel:getChild("num_forgecost"):setVisible(false)
		self._bagItemPanel:getChild("hero_gold_0"):setVisible(false)
	end
end

function EquipInfoLayer:vetifyCallback()
	cclog(".....鉴定")
	local opRet = self._heroModel:verifyItem(self._item)
	if opRet == 0 then
		self:Update()
	else
		cclog("鉴定不成功,error："..opRet)
	end
end

function EquipInfoLayer:equipCallback()
	cclog(".....装备")

	local opRet = self._heroModel:equipItem(self._item)
	if opRet == 0 then
		self:removeFromParent()
	else
		cclog("装备不成功,error："..opRet)
	end
end

function EquipInfoLayer:unequipCallback()
	cclog(".....脱装备")

	local opRet = self._heroModel:unEquipItem(self._item)
	if opRet == 0 then
		self:removeFromParent()
	else
		cclog("脱装备不成功,error："..opRet)
	end
end

function EquipInfoLayer:forgeCallback()
	cclog(".....强化")

	local opRet = self._heroModel:forgeItem(self._item)
	if opRet == 0 then
		cclog("强化物品成功")
		self:Update()
	else
		cclog("强化失败，error:"..opRet)
	end
end

function EquipInfoLayer:sellCallback()
	cclog(".....售出")

	local opRet = self._heroModel:sellItem(self._item)
	if opRet == 0 then
		cclog("售出物品成功！！！")
		self:removeFromParent()
	else
		cclog("售出失败，error:"..opRet)
	end
end

function EquipInfoLayer:Update()
	local randomStats = self._item:getRandomStats()

	for i = 1,#randomStats do
		local wordEntry = sItemRandomWordStore[randomStats[i]]
		self._bagItemPanel:getChild("Text_prop"..i .. "_desc"):setVisible(true)
		self._bagItemPanel:getChild("Text_prop"..i .. "_desc"):setString(wordEntry.desc)
		self._bagItemPanel:getChild("Text_prop_value"..i):setVisible(true)
		self._bagItemPanel:getChild("Text_prop_value"..i):setString("+"..tostring(wordEntry.word_value))
	end

	for i = #randomStats + 1,5 do
		self._bagItemPanel:getChild("Text_prop"..i .. "_desc"):setVisible(false)
		self._bagItemPanel:getChild("Text_prop_value"..i):setVisible(false)
	end
end

function EquipInfoLayer:backCallback(uiwidget)
	self:removeFromParent()
end

return EquipInfoLayer