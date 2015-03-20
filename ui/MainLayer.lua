
local ViewBase = require("ui.ViewBase")
local MainLayer = class("MainLayer", ViewBase)

MainLayer.RESOURCE_FILENAME = "ui/Town.csb"
MainLayer.AUTOSCALE = true

local mainModel = require("models.MainModel")
local heroModel = require("models.heroModel")

function MainLayer:onCreate()
	--local action = cc.CSLoader:createTimeline("ui/TownView_1.csb")
    --action:gotoFrameAndPlay(0,true)
    --self:runAction(action)

	--self:AutoScale()

	self._model = mainModel.new()
	self._heroModel = heroModel.new()

	self:addNodesEventListener()

	self:registerNotifyCenterEvent()

	self:Init()
end

function MainLayer:registerNotifyCenterEvent()
	NotifyCenter:addEventListener(Events.MONEY_CHANGE, handler(self,self.updateCoin))
end

function MainLayer:unregisterNotifyCenterEvent()
	NotifyCenter:removeEventListenersByEvent(Events.MONEY_CHANGE)
end

function MainLayer:onExit()
	self:unregisterNotifyCenterEvent()
end

function MainLayer:Init()
	self:getPanel():getChild("num_gold"):setString(self._heroModel:getCoin())
end

function MainLayer:addNodesEventListener()	
	self:getPanel():getChild("Button_addgold"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.AddCoinCallback)})
	self:getPanel():getChild("btn_ballet"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.toStageCallback)})
	self:getPanel():getChild("btn_hero"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.toHeroInfoCallback)})
	self:getPanel():getChild("btn_monster"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.toHeroesCallback)})
	self:getPanel():getChild("btn_chengjiu"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.toAchievementCallback)})
	self:getPanel():getChild("btn_shop"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.toShopLayer)})
	self:getPanel():getChild("Button_quest"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.toQuestCallback)})
	self:getPanel():getChild("Button_system"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.toStorageCallback)})

	self:getPanel():getChild("Button_GM"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.GMCallback)})
	
end

function MainLayer:GMCallback(uiwidget)
	local str = self:getPanel():getChild("TextField_1"):getString()
	cclog("str:"..str)
	local i,j = string.find(str,"%d+")
	print(i,j)
	cclog("value:"..string.sub(str,i,j))
    local result = tonumber(string.sub(str,i,j))

	local hero = StorageMgr:getPlayer(1)
	local bag = StorageMgr:getBagDataMgr()
	local teamData = StorageMgr:getTeamDataMgr()
	local stageModel = require("models.StageModel").new()
	--local stageData = StorageMgr:getStageDataMgr()
	assert(hero,"nil hero")
	if string.find(str,"additem") then
		bag:LootItem(result)
	elseif string.find(str,"setlevel") then
		hero:setLevel(result)
	elseif string.find(str,"addexp") then
		hero:giveExp(result)
	elseif string.find(str,"upgradespell") then
		hero:upgradeSpell(result)
	elseif string.find(str,"addcoin") then
		teamData:modifyCoin(result)
	elseif string.find(str,"passchapter") then
		--stageData:addPassChapter(result)
		stageModel:addPassChapter(result,3)
		StorageMgr:Save()
	end
end

function MainLayer:AddCoinCallback( uiwidget )
	--[[
	local shop = require("ui.ShopLayer").new()
	shop:switchToLayer(ShopTag.CoinConsume)
	self:addChild(shop)]]
	StorageMgr:getTeamDataMgr():modifyCoin(100)
end

function MainLayer:toStageCallback(uiwidget)
	local stage = require("ui.StageLayer").new()
	self:addChild(stage)
end

function MainLayer:toStorageCallback(uiwidget)
	self._model:backToStorage()

	UIMgr:EnterScene(GameState.STORAGE)
end

function MainLayer:toHeroInfoCallback(uiwidget )
	local heroinfo = require("ui.HeroInfoLayer").new()
	self:addChild(heroinfo)
end

function MainLayer:toHeroesCallback(uiwidget )
	local hero = require("ui.HeroesLayer").new()
	self:addChild(hero)
end

function MainLayer:toShopLayer( uiwidget)
	local shop = require("ui.ShopLayer").new()
	self:addChild(shop)
end

function MainLayer:toAchievementCallback()
	local shop = require("ui.AchievementLayer").new()
	self:addChild(shop)
end

function MainLayer:toQuestCallback()
	local quest = require("ui.QuestLayer").new()
	self:addChild(quest)
end

function MainLayer:updateCoin(t)
	assert(t and t.coin)
	self:getPanel():getChild("num_gold"):setString(t.coin)
end

return MainLayer