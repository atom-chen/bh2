local ViewBase = require("ui.ViewBase")
local HeroInfoLayer = class("HeroInfoLayer", ViewBase)

HeroInfoLayer.RESOURCE_FILENAME = "ui/HeroInfo.csb"
HeroInfoLayer.AUTOSCALE = true

--1.装备：强化，装卸，售出 ；   2. 技能:  学习，升级 

--面板攻击力 = (基础属性攻击 + 装备攻击 + 灵魂碎片攻击)  *(装备百分比+灵魂碎片百分比+ 祈福加成百分比)
--面板防御力 = (基础属性防御 + 装备防御 + 灵魂碎片防御)  *(装备百分比+灵魂碎片百分比+ 祈福加成百分比)



local heroModel = require("models.heroModel")

function HeroInfoLayer:onCreate()
	self:getPanel():getChild("btn_clouse"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.backMainCallback)})
	self._heroModel = heroModel.new()

	self:Init()
end

function HeroInfoLayer:addItem()
	local item = self._selectHero:getEquip(1)
	if iskindof(item,"Item") then return end
	self._selectHero:getEquip(i)
	cclog("-------为了测试，给hero装备")
	local item = require("utils.Item").new()
	item:Create(1)
	item._randomStats = {1,2,3}
	self._selectHero:Equip(item)
end

function HeroInfoLayer:Init()
	self:registerNotifyCenterEvent()

	self._heroModel:setSelectHero(1)
	self._selectHeroId = self._heroModel:getSelectHeroId()
	self._selectHero = self._heroModel:getSelectHero()

	--team
	for i = 1,4 do
		local class = self._heroModel:getPlayerIdInTeamByPos(i) --StorageMgr:getTeamDataMgr():getPlayerIdInTeamByPos(i)
		if class then
			local player = StorageMgr:getPlayer(class)
			assert(player,"nil player,class:"..class)
			local icon = player:getHeadIcon()
			local heroImage = self:getPanel():getChild("Panel_team_"..i):getChild("Image_icon_"..i)
			self:getPanel():getChild("Panel_team_"..i):getChild("Image_lock_"..i):setVisible(false)
			if i == 1 then
				self:getPanel():getChild("Panel_team_"..i):getChild("Image_select_"..i):setVisible(true)
			end
			heroImage:loadTexture(icon)
			heroImage:setTag(i)
			heroImage:setTouchEnabled(true)
			heroImage:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.teamMemberCallback)})
		else
			local heroImage = self:getPanel():getChild("Panel_team_"..i):getChild("Image_icon_"..i):setVisible(false)
		end
	end

	--init bag
	self._pageView = self:getPanel():getChild("hero_panel_goods"):getChild("PageView")
	local ownSlots = self._heroModel:getOwnSlots()
	for i = 0,2 do 
		local node1 = ccui.loadWidget("ui/HeroView_2.csb")
		local panel = node1:getChild("panel"):clone()
		for j = 0,20 do
	    	 local child = panel:getChild("bun_to_"..j)
	    	 local idx = i*20 + j + 1
	    	 if child then
	    	 	if i*20 + j + 1 <= ownSlots then
	    	 		if self._heroModel:getBagItem(idx) then
	    	 			child:setTag(idx)
	    	 			child:setTouchEnabled(true)
	    	 			child:loadTextureNormal(self._heroModel:getBagItem(idx):getDisplay())
	    	 			child:loadTexturePressed(self._heroModel:getBagItem(idx):getDisplay())
	    	 			child:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.selBagEquipCallback)})
	    	 		end
	    	 	else
	    	 		child:setTouchEnabled(false)
	    	 		--child:onPressStateChangedToDisabled()
	    	 		child:setBright(false)
	    	 	end
	    	 end
	    end
	    self._pageView:addPage(panel)
	end

	self:UpdateHeroInfo()
end

function HeroInfoLayer:UpdateHeroInfo()
	--更新属性：经验，等级，攻血防。。
	self:UpdateStats()
	--更新技能
	self:UpdateSpells()

	--更新装备，更新背包
	self:updateEquip()
end

function HeroInfoLayer:UpdateStats()
	self:getPanel():getChild("num_level"):setString(self._selectHero:getLevel())
	local curExp,nextLvExp = self._selectHero:getExp(),self._selectHero:getNextLvExp()
	self:getPanel():getChild("lab_jingyan"):setString(tostring(curExp).."/"..tostring(nextLvExp))
	self:getPanel():getChild("bar_jingyan"):setPercent(curExp/nextLvExp * 100)

	self:getPanel():getChild("num_hp"):setString(tostring(self._selectHero:getHp()))
	self:getPanel():getChild("num_atk"):setString(tostring(self._selectHero:getAttack()))
	self:getPanel():getChild("num_armor"):setString(tostring(self._selectHero:getDefence()))
end

function HeroInfoLayer:UpdateSpells()
	local learnSpells = self._selectHero:getLearnedSpells()
	local unlearnSpells = self._selectHero:getUnlearnSpells()
	for i = 1,#learnSpells do
		local spellId = learnSpells[i]
		local spell = self:getPanel():getChild("hsk_"..i-1)
		spell:loadTextureNormal(getSpellIcon(spellId))
		spell:setTouchEnabled(true)
		spell:setTag(i)
		spell:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.clickSpellCallback)})
	end
	for i = #learnSpells+1,4 do
		local spell = self:getPanel():getChild("hsk_"..i-1)
		spell:loadTextureNormal("ui/btn_clouse_1.png")
		spell:setTouchEnabled(true)
		spell:setTag(i)
		spell:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.clickSpellCallback)})
	end
end

function HeroInfoLayer:updateEquip(t)
	cclog("HeroInfoLayer:updateEquip()")
	--[[
	local equipId = 0
	if t and t.event == 1 then
		equipId = t.equipId
	end]]
	self:getPanel():getChild("Image_equip_select"):setVisible(false)

	--更新人物装备UI栏
	for i = 1,6 do
		local item = self._selectHero:getEquip(i)
		local equipBtn = self:getPanel():getChild("Image_equip"..i)
		equipBtn:setTag(i)
		if item and iskindof(item,"Item") then
			--[[if item:getId() == equipId then
				self:getPanel():getChild("Image_equip_select"):setVisible(true)
				self:getPanel():getChild("Image_equip_select"):pos(equipBtn:pos())
			end]]
			local displayPath = item:getDisplay()
			equipBtn:loadTexture(displayPath)
			equipBtn:setTouchEnabled(true)
			equipBtn:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.clickPlayerEquipCallback)})
		else
			equipBtn:loadTexture("ui/hero/hero_panel_hero_box.png")
			equipBtn:setTouchEnabled(false)
		end
	end

end

function HeroInfoLayer:UpdateBag()
	--更新背包UI栏
	for i = 0,2 do 
		for j = 0,15 do
			local panel = self._pageView:getPage(i)
			local child = panel:getChild("bun_to_"..j)
			local idx = i*15 + j + 1
			if child then
				if i*15 + j + 1 <= self._heroModel:getOwnSlots() then
					if self._heroModel:getBagItem(idx) then
						cclog("背包格子"..idx.."存在物品")
						child:setTag(idx)
						child:setTouchEnabled(true)
						child:loadTextureNormal(self._heroModel:getBagItem(idx):getDisplay())
						child:loadTexturePressed(self._heroModel:getBagItem(idx):getDisplay())
						child:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.selBagEquipCallback)})
					else
						cclog("背包格子"..idx.."不存在物品")
						child:loadTextureNormal("ui/hero/hero_panel_bag_box.png")
						child:loadTexturePressed("ui/hero/hero_panel_bag_box.png")
						child:setTouchEnabled(false)
						panel:getChild("img_select_0"):setVisible(false)
					end
				else
					child:setTouchEnabled(false)
					child:onPressStateChangedToDisabled()
				end
			end
	    end
	end
end

function HeroInfoLayer:updateItems(t)
	self:UpdateBag(t)
	self:updateEquip(t)
end

function HeroInfoLayer:getModel()
	return self._heroModel
end

function HeroInfoLayer:registerNotifyCenterEvent()
	cclog("注册消息。。。。。。。。。")
	NotifyCenter:addEventListener(Events.EQUIP_CHANGE, handler(self,self.updateItems))
	NotifyCenter:addEventListener(Events.PLAYER_PROPS_CHANGE,handler(self,self.UpdateStats))
end

function HeroInfoLayer:unregisterNotifyCenterEvent()
	NotifyCenter:removeEventListenersByEvent(Events.EQUIP_CHANGE)
	NotifyCenter:removeEventListenersByEvent(Events.PLAYER_PROPS_CHANGE)
end

function HeroInfoLayer:onExit()
	cclog("HeroInfoLayer:onExit()")

	self:unregisterNotifyCenterEvent()
end

function HeroInfoLayer:teamMemberCallback(uiwidget)
	local idx = uiwidget:getTag()
	local class = self._heroModel:getPlayerIdInTeamByPos(idx)
	if class ~= self._selectHeroId then
		cclog("click team index:"..idx..",class "..class)
		self._heroModel:setSelectHero(idx)
		self._selectHeroId = self._heroModel:getSelectHeroId()
		self._selectHero = self._heroModel:getSelectHero()

		--updateall
		self:UpdateHeroInfo()
	end

	for i = 1,4 do
		local selImage = self:getPanel():getChild("Panel_team_"..i):getChild("Image_select_"..i)
		if i == idx then
			selImage:setVisible(true)
		else
			selImage:setVisible(false)
		end
	end
end

function HeroInfoLayer:clickSpellCallback(uiwidget)
	local tag = uiwidget:getTag()
	local learnSpells = self._selectHero:getLearnedSpells()
	if learnSpells[tag] then
		cclog("click learned spell:"..tag)

		local spellinfo = require("ui.SpellInfoLayer").new()
		self:addChild(spellinfo)
		spellinfo:Init(learnSpells[tag])
	else
		cclog("click unlearned spell:"..tag)
	end
end

function HeroInfoLayer:selBagEquipCallback(uiwidget)
	cclog("click bag equip")
	uiwidget:getParent():getChild("img_select_0"):setVisible(true)
	uiwidget:getParent():getChild("img_select_0"):pos(uiwidget:pos())
	self._selBagEquipIdx = uiwidget:getTag()
	local item = self._heroModel:getBagItem(self._selBagEquipIdx)

	local equipInfoNode = require("ui.EquipInfoLayer").new()
	self:addChild(equipInfoNode)
	equipInfoNode:Init(item)
end

function HeroInfoLayer:clickPlayerEquipCallback(uiwidget)
	--[[
	local slot = uiwidget:getTag()
	if self._selectHero:getEquip(slot) then
		cclog("卸载装备"..slot)
		self._selectHero:unEquip(slot)
	end]]
	local slot = uiwidget:getTag()
	local item = self._selectHero:getEquip(slot)
	assert(item and iskindof(item,"Item"),"ERROR:WROND TYPE")

	local equipInfoNode = require("ui.EquipInfoLayer2").new()
	self:addChild(equipInfoNode)
	equipInfoNode:Init(item)
	equipInfoNode:getPanel():getChild("Panel1"):setPositionX(uiwidget:pos().x)

	self:getPanel():getChild("Image_equip_select"):pos(uiwidget:pos())
	self:getPanel():getChild("Image_equip_select"):setVisible(true)
end

function HeroInfoLayer:backMainCallback(uiwidget)
	self:removeFromParent()
end

return HeroInfoLayer