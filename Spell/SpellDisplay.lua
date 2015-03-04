local gameActor = require 'Object.GameActor'
local SpellDisplay = class("SpellDisplay")
SpellDisplay.__index = SpellDisplay

function SpellDisplay:ctor(id,spell)
	local info = sSpineStore[id]
	assert(info)
	self._render = gameActor.new(info.json,info.atlas)
	CC_SAFE_RETAIN(self._render)
	self._info = info
	self._spell = spell 	-- 技能指针
end

function SpellDisplay:getRender()
	return self._render
end

function SpellDisplay:getBox()
	local pos = self._spell._caster:pos()
	local face = self._spell._caster:getFace()
	local rect = self._render:getBox()
	if face == faceleft then
		rect.x = -rect.x - rect.width
	end
	rect.x = rect.x + pos.x
	rect.y = rect.y + pos.y
	return rect
end

function SpellDisplay:getZ()
	return self._render:getZOrder()
end

function SpellDisplay:onAdd(owner)
	self._owner = owner
	owner._actor:addChild(self._render)
	self._render:play(self._info.animation,false,1,sp.EventType.ANIMATION_EVENT,function(event)
			local data = event.eventData
			if data.name == "start" then
				--self:SkillStart()
			elseif data.name == "end" then
				--self:SkillEnd()
			else
				self:onTag(data.name)
			end
		end)
	self._render:setCallBack(self._info.animation,function(event)
		self:SkillEnd()
	end,sp.EventType.ANIMATION_END)
	self:SkillStart()
end

function SpellDisplay:onRemove()
	self._owner._actor:removeChild(self._render)
	CC_SAFE_RELEASE(self._render)
end

function SpellDisplay:SkillStart()
	self._spell:start()
end

function SpellDisplay:SkillEnd()
	self._spell:finish()
end

function SpellDisplay:onTag(name)
	self._spell:onTag_(name)
end

return SpellDisplay
