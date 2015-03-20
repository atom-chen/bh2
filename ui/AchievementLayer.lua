local ViewBase = require("ui.ViewBase")
local AchievementLayer = class("AchievementLayer", ViewBase)

AchievementLayer.RESOURCE_FILENAME = "ui/Achievement.csb"
AchievementLayer.AUTOSCALE = true

local AchievementModel = require("models.AchievementModel")
Max_Achievement_Count = 10

function AchievementLayer:onCreate()
	self._achievementModel = AchievementModel.new()

	self:getPanel():getChild("btn_clouse"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.backMainCallback)})

	self._list = self:getPanel():getChild("ListView")

	self:initAchievements()
end

function AchievementLayer:initAchievements()
	local achievementMgr = StorageMgr:getAchievementDataMgr()

	--self._list:setGravity(ccui.ListViewGravity.centerVertical)
	self._list:removeAllItems()
	for i = 1,Max_Achievement_Count do
		local achievement = self._achievementModel:getAchievementByIdx(i)
		if achievement and achievement:isSubmit() == false then
			local layout = ccui.Layout:create()
			local item = cc.CSLoader:createNode("ui/AchievementItem.csb")
			item:setTag(achievement:getId())
			layout:addChild(item)
			layout:setSize(item:getChild("success_box"):getSize())
			self._list:addChild(layout)

			item:getChild("mingcheng"):setString(achievement:getName())
			local jindu = tostring(achievement:getCurrentProgress()) .. "/" ..  tostring(achievement:getReqCount())
			item:getChild("word_jindu"):setString(jindu)
			item:getChild("word_mubiao"):setString(achievement:getDesc())
			item:getChild("word_jiangli"):setString(achievement:getRewardDesc())
			if achievement:isDone() == true then
				cclog("成就完成。。。。。。")
				item:getChild("success_btn_receive"):setBright(true)
				item:getChild("success_btn_manji"):setVisible(true)
				item:getChild("success_btn_receive"):setTag(i)
				item:getChild("success_btn_receive"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.receiveCallback)})
			else
				item:getChild("success_btn_receive"):setBright(false)
				item:getChild("success_btn_manji"):setVisible(false)
			end
			--item:getChild("success_btn_receive"):setString(achievement:getName())
		end
	end
end

function AchievementLayer:receiveCallback(uiwidget)
	local achievementId = uiwidget:getTag()
	local opRet = self._achievementModel:finishAchievement(achievementId)
	if opRet == 0 then
		cclog("完成成就成功")
		self:initAchievements()
	else
		cclog("完成成就失败，error:"..opRet)
	end
end

function AchievementLayer:backMainCallback(uiwidget)
	self:removeFromParent()
end

return AchievementLayer