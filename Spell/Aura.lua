--aura
local auraDisplay = require 'Spell.AuraDisplay'
Aura = class("Aura")
Aura.__index = Aura

AuraRace = {}
AuraRace.max = 30		-- 同MOD光环,如果RACE相同则会顶掉,如果RACE不同会叠加

function Aura:ctor(caster,spellEffect,displayID)
	self._info = spellEffect -- 保存静态信息
	self._caster = caster -- 施法者
	self._id = spellEffect.id
	self._aura = clone(spellEffect.aura[0])
	self._alive = true
	self._absorb = self._aura.base 		-- 给吸收用
	self._isPeriodic = self._aura.period > 0 -- 周期作用进行中
	self._periodicTimer = self._aura.period/1000

	self._duration = self._aura.duration
	if self._duration  == 0 then	-- 永久光环
		self._maxDuration = -1
		self._duration = 1
	end

	self._maxStackCount = self._aura.stackcount

	
	self._stackcount = 0

	self.AuraEffectHandler = 
	{
		[AuraMod.tiggerSpell] = handler(self, self.effectCastSpell),
		[AuraMod.impactTarget] = handler(self,self.impactTarget),
	}
	local displayEntry = sSpellDisplayStore[displayID]
	self._display = nil
	if displayEntry then
		self._display = auraDisplay.new(displayEntry.buff,self._caster,self)
	end
end

function Aura:onAdd()
	if self._display then
		self._display:onAdd()
	end
end

function Aura:onRemove()
	if self._display then
		self._display:onRemove()
	end
end

function Aura:onTrigger()
	if( self:GetTriggerType() ~= 0 ) then
		local rand = math.random(100)
		rand = rand/100
		if rand <= self._aura.trigchance then
			self.AuraEffectHandler[self._aura.aura](self,true)
		end
	end
end

function Aura:update(dt)
	if self._display then
		self._display:update(dt)
	end
	if self._isPeriodic then
		self._periodicTimer = self._periodicTimer - dt
		if self._periodicTimer < 0 then
			self._periodicTimer = self._periodicTimer + self:GetPeriod()/1000
			self:PeriodicTick()
		end
	end
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

function Aura:PeriodicTick()
	self.AuraEffectHandler[self._aura.aura](self,true)
end

--[[
AuraEffectHandler
]]
function Aura:effectCastSpell(apply)
	self._isPeriodic = self:GetPeriod()>0
	if apply then
		local spellId = self._aura.trigspell
		self._caster:TriggerSpell(spellId)
	end
end

function Aura:impactTarget(apply)
	self._isPeriodic = self:GetPeriod()>0
	if apply then
		local targets = self._caster:getImpactTargets()
		local entry = self._info
		local log = 
		{
			damageType = entry.damageType,
			damage = entry.value_base,
			spellId = self._caster._spellId,
			valueMod = entry.valueMod,
			value_pct = entry.value_pct,
			hitback = entry.hitback,
			hitdown = entry.hitdown,
		}
		for unit,_ in pairs(targets) do
			target:onHit(clone(log))
			self._caster:getOwner():combo()
		end
	end
end

function Aura:Absorb(damage)
	local absorb = damage
	self._absorb = self._absorb - damage
	damage = 0
	if self._absorb <= 0 then
		self._alive = false
		absorb = absorb + self._absorb  -- 实际吸收=应该吸收+未吸收
		damage = -1*self._absorb
	end
	return absorb,damage
end

return Aura