local ViewBase = require("ui.ViewBase")
local SpellInfoLayer = class("SpellInfoLayer", ViewBase)

SpellInfoLayer.RESOURCE_FILENAME = "ui/SpellInfo.csb"
SpellInfoLayer.AUTOSCALE = true

--local heroModel = require("models.heroModel")

function SpellInfoLayer:onCreate()
	local bg = self:getPanel():getChild("Image_bg")
	bg:setTouchEnabled(true)
	bg:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.backCallback)})

	self:getPanel():getChild("Button_upgradeSkill"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.upgradeSkillCallback)})
	
	self:registerNotifyCenterEvent()
end

function SpellInfoLayer:Init(spellId)
	self._heroModel = self:getParent():getModel()
	self._spellId = spellId

	local curLvNode = gSpellChain[spellId]
	local nextSpellId = gFirstSpellChain[curLvNode.firstId][curLvNode.rank + 1]
	self:getPanel():getChild("Image_spellIcon"):loadTexture(getSpellIcon(spellId))
	self:getPanel():getChild("Text_spellname"):setString(tostring(getSpellName(spellId)))
	self:getPanel():getChild("Text_Lv"):setString(tostring(curLvNode.rank))
	self:getPanel():getChild("Text_limitDesc"):setString(tostring(curLvNode.reqLv))
	self:getPanel():getChild("Text_spellDesc"):setString(tostring(getSpellDesc(spellId)))
	if nextSpellId then
		self:getPanel():getChild("Text_nextLvDesc"):setString(tostring(getSpellDesc(nextSpellId)))
	else
		self:getPanel():getChild("Text_nextLvDesc"):setString(tostring(""))
	end

	self:getPanel():getChild("num_cost"):setString(curLvNode.cost)
end

function SpellInfoLayer:registerNotifyCenterEvent()
	NotifyCenter:addEventListener(Events.UPGRADE_SPELL, handler(self,self.updateSpell))
end

function SpellInfoLayer:unregisterNotifyCenterEvent()
	NotifyCenter:removeEventListenersByEvent(Events.UPGRADE_SPELL)
end

function SpellInfoLayer:onExit()
	self:unregisterNotifyCenterEvent()
end

function SpellInfoLayer:updateSpell(t)
	cclog("---------------SpellInfoLayer:updateSpell")
	local spellId = t.spellId
	assert(spellId)
	self:Init(spellId)
end

function SpellInfoLayer:upgradeSkillCallback(uiwidget)
	local opRet = self._heroModel:upgradeSpell(self._spellId)
	if opRet == 0 then
		cclog("upgradeSpell OK")
	else
		cclog("upgradeSpell(" .. self._spellId ..") error:"..opRet)
	end
end

function SpellInfoLayer:backCallback(uiwidget)
	self:removeFromParent()
end

return SpellInfoLayer