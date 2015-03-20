local ViewBase = require("ui.ViewBase")
local BattleWinLayer = class("BattleWinLayer", ViewBase)

BattleWinLayer.RESOURCE_FILENAME = "ui/BattleSuccess.csb"
BattleWinLayer.AUTOSCALE = true

local AchievementModel = require("models.AchievementModel")

function BattleWinLayer:onCreate()
	self._achievementModel = AchievementModel.new()
end

function BattleWinLayer:Init(chapterId)
	self._chapterId = chapterId

	self:getPanel():getChild("battle_replay"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.replayCallback)})
	self:getPanel():getChild("battle_toHero"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.toHeroCallback)})
	self:getPanel():getChild("battle_next_chapter"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.nextChapterCallback)})

	local starCount = 0
	local entry = gChapterChain[chapterId]
    for i = 0,2 do
        local achievementId = gChapterChain[chapterId].achievements[i]
        assert(achievementId and achievementId ~= 0)
        local achievement = self._achievementModel:getAchievement(achievementId)

        local item = self:getPanel():getChild("ListView_2"):getChild("Panel_"..i+1)
		item:getChild("mingcheng"):setString(achievement:getName())
		local jindu = tostring(achievement:getCurrentProgress()) .. "/" ..  tostring(achievement:getReqCount())
		item:getChild("word_jindu"):setString(jindu)
		item:getChild("word_mubiao"):setString(achievement:getDesc())
		item:getChild("word_jiangli"):setString(achievement:getRewardDesc())
		if achievement:isDone() == true and achievement:isSubmit() == false then
			cclog("成就".. i + 1 .."完成")
			starCount = starCount + 1
			item:setTag(achievement:getId())
			item:getChild("success_btn_receive"):setBright(true)
			--item:getChild("success_btn_manji"):setVisible(true)
			item:getChild("success_btn_receive"):setTag(i)
			item:getChild("success_btn_receive"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.receiveCallback)})
		elseif achievement:isSubmit() == true then
			cclog("成就".. i + 1 .."提交")
			starCount = starCount + 1
			item:getChild("success_btn_receive"):setBright(false)
			--item:getChild("success_btn_manji"):setVisible(false)
		end
    end

    for i = 1,starCount do
    	self:getPanel():getChild("Image_star"..i):setVisible(true)
    end
    for i = starCount+1,3 do
    	self:getPanel():getChild("Image_star"..i):setVisible(false)
    end
end

function BattleWinLayer:receiveCallback(uiwidget)
	local achievementId = uiwidget:getTag()
	local opRet = self._achievementModel:finishAchievement(achievementId)
	if opRet == 0 then
		cclog("完成成就成功")
	else
		cclog("完成成就失败，error:"..opRet)
	end
end

function BattleWinLayer:replayCallback( )
	-- body
end

function BattleWinLayer:toHeroCallback( )
	UIMgr:EnterScene(GameState.MAIN)
	local mainLayer = UIMgr:getMainLayer()
	if mainLayer then
		mainLayer:toHeroInfoCallback()
	end
end

function BattleWinLayer:nextChapterCallback()
	local entry = gChapterChain[self._chapterId]
	assert(entry)
	local firstId = entry.firstId
	local rank = entry.rank
	local nextId = gFirstAchievementChain[firstId][rank + 1] or 0
	if nextId ~= 0 then
		GameLogic:init(entry.stage,nextId)
	else
		local newStageId = 0
	end
end

return BattleWinLayer