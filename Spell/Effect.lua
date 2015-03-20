local effectHandlers = require 'Spell.Handlers'

local Effect = class("Effect")
Effect.__index = Effect

-- actionTag = 
local instant = 0
local tagTigger = 1

function Effect:ctor(spell,idx)
	local effectInfo = sSpellEffects[idx]
	assert(effectInfo)
	self._info = effectInfo
	self._spell = spell
	self._applied = false
	self._tigger = false
	self._targets = {} -- 作用目标
-- 一个switch case的写法
	self._applyFuncs = 
	{
		[instant] = handler(self,self.Instant),
		[tagTigger] = handler(self,self.TagTigger),
	}
end

function Effect:apply(caster,targets)
	if self:applied() then return end
	local func = self._applyFuncs[self._info.actionTag]
	if func then
		func(caster,targets)
	else
		cclog("错误的spelleffect actionTag :%d effectId:%d",self._info.actionTag,self._info.id)
		assert(false)
	end
end

function Effect:isTagTigger()
	return self._info.actionTag == tagTigger
end

function Effect:On()
	self._tigger = true
end

function Effect:Off()
	self._tigger = false
end

function Effect:Instant(caster,targets)
	for target,v in pairs(targets) do
		self:Handle(caster,target)
	end
	self._applied = true
end

function Effect:TagTigger(caster,targets)
	local tiggered = self._tigger
	if tiggered then
		local all_handle = true
		for target,v in pairs(targets) do
			if not v and self._spell:checkRange(target) then
				self:Handle(caster,target)
				targets[target] = true
			else
				all_handle = false
			end
		end
		self._applied = all_handle
	end
end

function Effect:applied()
	return self._applied
end

function Effect:Handle(caster,target)
	effectHandlers[self._info.effect](self,caster,target)
end

return Effect