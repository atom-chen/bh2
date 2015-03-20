local ViewBase = require("ui.ViewBase")
local FormationLayer = class("FormationLayer", ViewBase)

FormationLayer.RESOURCE_FILENAME = "ui/Formation.csb"
FormationLayer.AUTOSCALE = true

--local stageModel = require("models.StageModel")
local heroModel = require("models.heroModel")

function FormationLayer:onCreate()
	self._heroModel = heroModel.new()

	self:getPanel():getChild("Button_enterbattle"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.enterBattleCallback)})
	self:getPanel():getChild("btn_back"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.backMainCallback)})

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
end

function FormationLayer:Init(stageId,chapterId)
	self._chapterId = chapterId

	self:UpdateChapterInfo()
end

function FormationLayer:getTeamLevel()
	local maxLevel = 0
	for i = 1,4 do
		local class = self._heroModel:getPlayerIdInTeamByPos(i)
		if class then
			local player = StorageMgr:getPlayer(class)
			if player:getLevel() > maxLevel then
				maxLevel = player:getLevel()
			end
		end
	end
	return maxLevel
end

function FormationLayer:UpdateChapterInfo()
	local teamLevel = self:getTeamLevel()
	self:getPanel():getChild("team_lv"):setString(tostring(teamLevel))

	local entry = gChapterChain[self._chapterId]
	assert(entry,"nil chapter entry")

	self:getPanel():getChild("Text_chapterLv"):setString(tostring(entry.reqLv))

	local teamLevel = self:getTeamLevel()
	if teamLevel > entry.reqLv then
		self:getPanel():getChild("Text_coin_rew"):setString(tostring(3))
		self:getPanel():getChild("Text_exp_rew"):setString(tostring(3))
		self:getPanel():getChild("Text_item_rew"):setString(tostring(3))
	elseif teamLevel <  entry.reqLv then
		self:getPanel():getChild("Text_coin_rew"):setString(tostring(3))
		self:getPanel():getChild("Text_exp_rew"):setString(tostring(3))
		self:getPanel():getChild("Text_item_rew"):setString(tostring(3))
	else
		self:getPanel():getChild("Text_coin_rew"):setString(tostring(3))
		self:getPanel():getChild("Text_exp_rew"):setString(tostring(3))
		self:getPanel():getChild("Text_item_rew"):setString(tostring(3))
	end
end

function FormationLayer:UpdateTeam()
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

function FormationLayer:teamHeroCallback(uiwidget)
	local pos = uiwidget:getTag()
	local class = self._heroModel:getPlayerIdInTeamByPos(pos)
	if class then
		--离队
		self._class = class
		local opRet = self._heroModel:opHeroBattleTeam(self._class,0)
		if opRet == 0 then
			cclog("离队成功")
			self:UpdateTeam()
		else
			cclog("离队失败")
		end
	end
end

function FormationLayer:selectHeroCallback(uiwidget)
	cclog("FormationLayer:selectHeroCallback")
	self._class = uiwidget:getTag()
	if StorageMgr:hasPlayer(self._class) then
		--入队
		local opRet = self._heroModel:opHeroBattleTeam(self._class,1)
		if opRet == 0 then
			cclog("入队成功")
		else
			cclog("入队失败")
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
	self:UpdateTeam()

	self:getPanel():getChild("Image_select"):pos(uiwidget:pos())
end

function FormationLayer:enterBattleCallback(uiwidget)
	local team = self._heroModel:getBattleTeam()
	if #team == 0 then
		UIMgr:ShowInfo("至少要有一个英雄在队伍中")
		return
	elseif #team < 4 then

	elseif #team > 4 then
		assert(false,"player counts should not be more than 4!!")
		return
	end

	local entry = gChapterChain[self._chapterId]
	assert(entry,"nil chapter")
	self:getParent()._model:enterBattle(entry.stage,self._chapterId)
end

function FormationLayer:backMainCallback(uiwidget)
	local team = self._heroModel:getBattleTeam()
	if #team == 0 then
		UIMgr:ShowInfo("至少要有一个英雄在队伍中")
		return
	elseif #team < 4 then

	elseif #team > 4 then
		assert(false,"player counts should not be more than 4!!")
		return
	end

	self:removeFromParent()
end

return FormationLayer