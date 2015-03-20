local ViewBase = require("ui.ViewBase")
local StageLayer = class("StageLayer", ViewBase)

StageLayer.RESOURCE_FILENAME = "ui/Stage.csb"
StageLayer.AUTOSCALE = true

local stageModel = require("models.StageModel")

function StageLayer:onCreate()
	self._model = stageModel.new()
	self._curStage,self._curChapter = 0,0

	self:addNodesEventListener()

	self._pageView = ccui.PageView:create()
	for i = 1,5 do 
		local layout = ccui.Layout:create()
        
        local node = cc.CSLoader:createNode("ui/TollgateView_".. i+1 ..".csb")
        display:AutoScale(node:getChild("Panel"):getChild("tollgate_continent_"..i))
        --[[
        local action = cc.CSLoader:createTimeline("ui/TollgateView_".. i+1 ..".csb")
	    action:gotoFrameAndPlay(0,false)
	    node:runAction(action)]]
	    for j = 1,node:getChild("Panel"):getChildrenCount() do
	    	 local child = node:getChild("Panel"):getChildren()[j]
	    	 local name = child:getName()
	    	 if string.find(name,"btn_spot_") or string.find(name,"btn_guide") then
	    	 	child:setVisible(false)
	    	 end
	    end

        layout:setContentSize(node:getSize())
        node:setName("page")
		layout:addChild(node)
		self._pageView:addPage(layout)
	end
	self._pageView:setSize(cc.size(960,640))
	
	self:getResourceNode():addChild(self._pageView,-1)

	--self:Update()
	local stage = self._model:getMaxStage()
    local chapter = self._model:getNewestChapter()
    cclog("-------最新章节Id:"..chapter)
    self._newestChapter = chapter
    self:Update(stage,chapter)
end

function StageLayer:addNodesEventListener()
	self:getPanel():getChild("tollgate_btn_battle"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.battleCallback)})
	self:getPanel():getChild("tollgate_btn_back"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.backMainCallback)})
	self:getPanel():getChild("btn_toyincan"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.toChallengeCallback)})

	self:getPanel():getChild("tollgate_btn_arrow_L"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.toPrevStageCallback)})
	self:getPanel():getChild("tollgate_btn_arrow_R"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.toNextStageCallback)})
end

function StageLayer:getModel( ... )
	return self._model
end

function StageLayer:Update(stage,chapter)
	assert( stage and chapter)
	if self._curStage == stage and self._curChapter == chapter then
		return
	end
	if self._model:hasOpenedStage(stage) == false then
		return
	end

	self._curStage,self._curChapter = stage,chapter
	cclog("curStageId:"..self._curStage)
	cclog("curChapter:"..self._curChapter)
	self._pageView:scrollToPage(self._curStage-1)

	local chapterIdx = gChapterChain[self._curChapter].rank
	cclog("chapterIdx:"..chapterIdx)

	local layout = self._pageView:getPage(self._curStage - 1)
	local node = layout:getChildByName("page")
	local uiwidget = node:getChild("Panel"):getChild("btn_spot_"..chapterIdx)

	local pos = uiwidget:pos()
	node:getChild("Panel"):getChild("btn_guide"):setVisible(true)
	node:getChild("Panel"):getChild("btn_guide"):pos(pos)

	local maxChapterCount = gChapterChain[self._newestChapter].rank
    for i = 1,maxChapterCount do
    	if i ~= chapterIdx then
    		node:getChild("Panel"):getChild("btn_spot_"..i):setTag(i)
			node:getChild("Panel"):getChild("btn_spot_"..i):setVisible(true)
			node:getChild("Panel"):getChild("btn_spot_"..i):setTouchEnabled(true)
			node:getChild("Panel"):getChild("btn_spot_"..i):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.chooseChapterCallback)})
		else
			node:getChild("Panel"):getChild("btn_spot_"..i):setVisible(false)
		end
	end

    self:getPanel():getChild("label_stage_progress"):setString(tostring(self._curStage).. "-"..tostring(self._curChapter))
    self:getPanel():getChild("tollgate_zhanli_0"):getChild("num_zhanli_1"):setString(sChapterStore[self._curChapter].enemyCombat)
    self:getPanel():getChild("tollgate_zhanli_0"):getChild("num_zhanli_0"):setString(0)

    local totalStar = self._model:getStageStar(self._curStage)
    self:getPanel():getChild("num_xing_now"):setString(tostring(totalStar))
    local chaptersCount = #gFirstChapterChain[self._curStage]
    self:getPanel():getChild("num_xing_max"):setString(tostring(chaptersCount * 3))
end

function StageLayer:chooseChapterCallback(uiwidget)
	local pageIdx = self._pageView:getCurPageIndex()
	local layout = self._pageView:getPage(pageIdx)
	local node = layout:getChildByName("page")
	node:getChild("Panel"):getChild("btn_guide"):pos(uiwidget:pos())
	

    local chapterIdx = uiwidget:getTag()
    local maxChapterCount = gChapterChain[self._newestChapter].rank
    --[[
    cclog("----maxChapterCount:"..maxChapterCount)
    for i = 1,maxChapterCount do
    	if i ~= chapterIdx then
			node:getChild("Panel"):getChild("btn_spot_"..i):setVisible(true)
		else
			node:getChild("Panel"):getChild("btn_spot_"..i):setVisible(false)
		end
	end]]

    local chapterId = gFirstChapterChain[pageIdx + 1][chapterIdx]
    assert(chapterId,"nil chapterId,chapterIdx:"..chapterIdx)

   self:Update(pageIdx + 1,chapterIdx)
end

function StageLayer:battleCallback(uiwidget)
	local tip = require("ui.TipLayer").new()
	self:addChild(tip)
end

function StageLayer:toFormationCallback(uiwidget)
	local formation = require("ui.FormationLayer").new()
	self:addChild(formation)

	assert(self._curStage and self._curChapter)
	formation:Init(self._curStage,self._curStage)
end

function StageLayer:toChallengeCallback(uiwidget )
	local challengeStage = require("ui.ChallengeStageLayer").new()
	self:addChild(challengeStage)
	challengeStage:Init()
end

function StageLayer:toPrevStageCallback()
	local pageIdx = self._pageView:getCurPageIndex()
	if pageIdx > 0 then
		self._pageView:scrollToPage(pageIdx - 1)
	end 
end

function StageLayer:toNextStageCallback()
	local pageIdx = self._pageView:getCurPageIndex()
	if pageIdx < 4 then
		self._pageView:scrollToPage(pageIdx + 1)
	end 
end

function StageLayer:backMainCallback(uiwidget)
	self:removeFromParent()
end

return StageLayer