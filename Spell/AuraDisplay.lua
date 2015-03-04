local gameActor = require 'Object.GameActor'
local AuraDisplay = class("AuraDisplay")
AuraDisplay.__index = AuraDisplay

function AuraDisplay:ctor(displayId,caster,aura)
	local entry = sSpineStore[displayId]
	assert(entry)
	self._entry = entry
	self._caster = caster
	self._aura = aura
	self._render = nil
end

function AuraDisplay:onAdd()
	self._render = gameActor.new(self._entry.json,self._entry.atlas)
	self._caster._actor:addChild(self._render)
	self._render:play(self._entry.animation.."_start",false,1,sp.EventType.ANIMATION_END,function(event)
		self._render:setCallBack(self._entry.animation.."_start",nil,sp.EventType.ANIMATION_END)
		self._still = true
		end)
end

function AuraDisplay:onRemove()
	cclog("AuraDisplay onRemove")
	self._render:play(self._entry.animation.."_end",false,1,sp.EventType.ANIMATION_END,function(event)
		self._render:setCallBack(self._entry.animation.."_end",nil,sp.EventType.ANIMATION_END)
		self._render:runAction(cc.RemoveSelf:create())
		end)
end

function AuraDisplay:update(dt)
	if self._still then
		cclog("play "..self._entry.animation.."_ing")
		self._render:play(self._entry.animation.."_ing",true)
		self._still = nil
	end
end

return AuraDisplay
