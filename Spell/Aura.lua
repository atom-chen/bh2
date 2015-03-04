--aura
local auraDisplay = require 'Spell.AuraDisplay'
Aura = class("Aura")
Aura.__index = Aura

AuraMod = 
{
	none = 0,
	dummy = 1,			-- 哑效果
	addattack = 2,		-- modify attack (基础伤害)
	adddamage = 3,		-- modify damage (额外伤害)
	addresist = 4,		-- modify 抵抗伤害
	addresistratio = 5,	-- modify 
	silence = 6,		-- 沉默
	reduce_physic_resist = 7,	-- 降低物理抗性
	absorbdamage = 8,		-- 吸收伤害
	max = 9,
}
--[[
AuraEffectHandler =
{
	--[0] = handler(self, self:effectCastSpell)
}
]]

AuraRace = {}
AuraRace.max = 30		-- 同MOD光环,如果RACE相同则会顶掉,如果RACE不同会叠加

function Aura:ctor(caster,spellEffect,displayID)
	self._info = spellEffect -- 保存静态信息
	self._caster = caster -- 施法者
	self._id = spellEffect.id
	self._aura = clone(spellEffect.aura[0])
	self._alive = true
	self._absorb = self._aura.base 		-- 给吸收用

	self._duration = self._aura.duration
	if self._duration  == 0 then	-- 永久光环
		self._maxDuration = -1
		self._duration = 1
	end

	self._maxStackCount = self._aura.stackcount

	
	self._stackcount = 0

	self.AuraEffectHandler = 
	{
		[1] = handler(self, self.effectCastSpell),
	}
	local displayEntry = sSpellDisplayStore[displayID]
	self._display = auraDisplay.new(displayEntry.buff,self._caster,self)
end

function Aura:onAdd()
	self._display:onAdd()
end

function Aura:onRemove()
	self._display:onRemove()
end

function Aura:onTrigger()
	if( self:GetTriggerType() ~= 0 ) then
		local rand = math.random(100)
		rand = rand/100
		if rand <= self._aura.trigchance then
			self.AuraEffectHandler[self:GetTriggerType()](self,true)
		end
	end
end

function Aura:update(dt)
	self._display:update(dt)
	return self:isAlive()
end


function Aura:GetMod()
	return self._aura.mod 
end
function Aura:GetBase()
	return self._aura.base
end

function Aura:GetPct()
	return self._aura.pct
end

function Aura:GetAmplitude( )
	return self._aura.amplitude
end

function Aura:durationReset()
	if not self:permanent() then
		self._duration = self._maxDuration
	end
end

function Aura:durationPass( dt )
	if not self:permanent() then
		self._duration = self._duration - dt
	end
end

function Aura:setAmplitude( amplitude )
	self._aura.amplitude = amplitude
end

-- 是否永久存在
function Aura:permanent()
	if self._maxDuration == -1 then
		return true
	end
	return false
end

function Aura:isAlive()
	return self._alive
end

function Aura:GetDuration()
	return self._duration
end

function Aura:GetRace()
	return self._aura.race
end

function Aura:GetPeriod()
	return self._aura.period
end

function Aura:isTrigger()
	return self._aura.trigmod > 0
end

function Aura:GetTriggerType()
	return self._aura.trigmod
end

--[[
AuraEffectHandler
]]
function Aura:effectCastSpell(apply)
	if apply then
		local spellId = self._aura.trigspell
		self._caster:TriggerSpell(spellId)
	end
end

function Aura:Absorb(damage)
	local absorb = damage
	self._absorb = self._absorb - damage
	damage = 0
	if self._absorb <= 0 then
		self._alive = false
		absorb = damage + self._absorb
		damage = -1*self._absorb
	end
	return absorb,damage
end

return Aura