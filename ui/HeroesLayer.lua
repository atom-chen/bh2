local ViewBase = require("ui.ViewBase")
local HeroesLayer = class("HeroesLayer", ViewBase)

HeroesLayer.RESOURCE_FILENAME = "ui/Heros.csb"
HeroesLayer.AUTOSCALE = true

local heroModel = require("models.heroModel")

function HeroesLayer:onCreate()
	self._heroModel = heroModel.new()
	self:getPanel():getChild("public_btn_back"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.backMainCallback)})
	self:getPanel():getChild("btn_unlock"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.unlockHeroCallback)})
	for i = 1,12 do
		self:getPanel():getChild("mo_"..i):setTag(i)
		self:getPanel():getChild("mo_"..i):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.selectHeroCallback)})
		local class = i
		if StorageMgr:hasPlayer(class) then
			if self:getPanel():getChild("img_lock_"..class) then
				self:getPanel():getChild("img_lock_"..class):setVisible(false)
			end
		end
	end
	for i = 1,4 do
		self:getPanel():getChild("hero_"..i):setTag(i)
		self:getPanel():getChild("hero_"..i):setTouchEnabled(true)
		self:getPanel():getChild("hero_"..i):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.teamHeroCallback)})
		local class = self._heroModel:getPlayerIdInTeamByPos(i)
		if class then
			local player = StorageMgr:getPlayer(class)
			assert(player,"nil player,class:"..class)
			local icon = player:getHeadIcon()
			cclog("player "..i.." icon path:"..icon)
			self:getPanel():getChild("hero_"..i):loadTexture(icon)
		else
			self:getPanel():getChild("hero_"..i):loadTexture("ui/hero/hero_panel_hero_box.png")
		end
	end

	self._class = 1

	self:UpdateHeroInfo(self._class)
end

function HeroesLayer:Update()
	self:UpdateTeam()
	self:UpdateHeroInfo(self._class)
end

function HeroesLayer:UpdateHeroesBar( )
	for i = 1,12 do
		if StorageMgr:hasPlayer(i) then
			if self:getPanel():getChild("img_lock_"..i) then
				self:getPanel():getChild("img_lock_"..i):setVisible(false)
			end
		end
	end
end

function HeroesLayer:UpdateTeam()
	for i = 1,4 do
		self:getPanel():getChild("hero_"..i):setTag(i)
		local class = self._heroModel:getPlayerIdInTeamByPos(i)
		if class then
			local player = StorageMgr:getPlayer(class)
			assert(player,"nil player,class:"..class)
			local icon = player:getHeadIcon()
			cclog("player "..i.." icon path:"..icon)
			self:getPanel():getChild("hero_"..i):loadTexture(icon)
		else
			self:getPanel():getChild("hero_"..i):loadTexture("ui/hero/hero_panel_hero_box.png")
		end
	end
end

function HeroesLayer:UpdateHeroInfo(class)
	self:getPanel():getChild("Image_select"):setVisible(true)
	self:getPanel():getChild("Image_select"):pos(self:getPanel():getChild("mo_"..class):pos())

	local hp,atk,defence,curExp,nextExp = 0,0,0,0,0
	local entry = sPlayerCreateInfoStore[class]
	local spells = entry.skill
	if StorageMgr:hasPlayer(class) then
		local player = StorageMgr:getPlayer(class)
		hp,atk,defence = player:getHp(),player:getAttack(),player:getDefence()
		curExp,nextExp = player:getExp(),player:getNextLvExp()
		self:getPanel():getChild("btn_unlock"):setVisible(false)
		self:getPanel():getChild("public_gold"):setVisible(false)
		self:getPanel():getChild("num_cost"):setVisible(false)

		self:getPanel():getChild("Label_exp"):setVisible(true)
		self:getPanel():getChild("bar_exp"):setVisible(true)
		self:getPanel():getChild("Label_exp"):setString(tostring(curExp).."/"..tostring(nextExp))
		self:getPanel():getChild("bar_exp"):setPercent(curExp/nextExp * 100)
		self:getPanel():getChild("level"):setString(player:getLevel())
	else
		assert(entry,"nil entry")
		hp,atk,defence = entry.hp,entry.atk,entry.defence
		self:getPanel():getChild("btn_unlock"):setVisible(true)
		self:getPanel():getChild("public_gold"):setVisible(true)
		self:getPanel():getChild("num_cost"):setVisible(true)

		self:getPanel():getChild("Label_exp"):setVisible(false)
		self:getPanel():getChild("bar_exp"):setVisible(false)

		self:getPanel():getChild("level"):setString(0)
	end

	for i = 1,4 do 
		local spellId = spells[i-1]
		local icon = getSpellIcon(spellId)
		assert(self:getPanel():getChild("Image_spellbg"))
		self:getPanel():getChild("Image_spellbg"):getChild("Image_spell"..i):loadTexture(icon)
		self:getPanel():getChild("Image_spellbg"):getChild("Image_spell"..i):setTag(spellId)
	end

	for i = 1,entry.starLevel do
		self:getPanel():getChild("Image_star"..i):setVisible(true)
	end
	for i = entry.starLevel+1,5 do
		self:getPanel():getChild("Image_star"..i):setVisible(false)
	end

	self:getPanel():getChild("num_hp"):setString(tostring(hp))
	self:getPanel():getChild("num_atk"):setString(tostring(atk))
	self:getPanel():getChild("num_armor"):setString(tostring(defence))

	local localeEntry = sLocalePlayerStore[class]
	self:getPanel():getChild("name"):setString(tostring(localeEntry.name[0]))
	self:getPanel():getChild("img_miaoshu"):getChild("profile"):setString(tostring(localeEntry.desc[0])) --人物描述
end

function HeroesLayer:teamHeroCallback(uiwidget)
	local pos = uiwidget:getTag()
	local class = self._heroModel:getPlayerIdInTeamByPos(pos)
	if class then
		--离队
		self._class = class
		local opRet = self._heroModel:opHeroBattleTeam(self._class,0)
		if opRet == 0 then
			cclog("离队成功")
			self:Update()
		else
			cclog("离队失败")
		end
	end
end

function HeroesLayer:selectHeroCallback(uiwidget)
	cclog("HeroesLayer:selectHeroCallback")
	self._class = uiwidget:getTag()
	if StorageMgr:hasPlayer(self._class) then
		--入队
		local opRet = self._heroModel:opHeroBattleTeam(self._class,1)
		if opRet == 0 then
			cclog("英雄"..self._class.."入队成功")
		else
			cclog("英雄"..self._class.."入队失败,error:"..opRet)
		end
	else
		local entry = sHireCostStore[self._class]
		local cost = entry.cost
		self:getPanel():getChild("btn_unlock"):setVisible(true)
		self:getPanel():getChild("btn_unlock"):setTouchEnabled(true)
		self:getPanel():getChild("num_cost"):setString(tostring(cost))
		self:getPanel():getChild("num_cost"):setVisible(true)
		self:getPanel():getChild("public_gold"):setVisible(true)
	end 
	self:Update()
end

function HeroesLayer:backMainCallback(uiwidget)
	local team = self._heroModel:getBattleTeam()
	if table.nums(team) < 1 then
		UIMgr:ShowInfo("队伍中至少要有一个英雄")
		return
	end

	self:removeFromParent()

	StorageMgr:Save()
end

function HeroesLayer:unlockHeroCallback(uiwidget)
	local opRet = self._heroModel:hireHero(self._class)
	if opRet == 0 then
		cclog("解锁英雄成功")
		self:Update()
		self:UpdateHeroesBar()
	else
		cclog("解锁英雄失败，error:"..opRet)
	end
end

return HeroesLayer