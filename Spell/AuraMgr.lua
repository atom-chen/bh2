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
	armor_penetration = 9,
	tiggerSpell = 10,		-- 触发技能
	impactTarget = 11,
	max  = 12,
}

-- 触发型光环
AuraTriggerType = 
{
	none = 0,
	onhit = 1,
	impact = 2,
	max = 3,
}

--AuraMgr
local Aura = require "Spell.Aura"

AuraMgr = class("AuraMgr")
AuraMgr.__index = AuraMgr

function AuraMgr:ctor()
	self._auraList = {}
	self._auraCount = 0
	self._owner = nil					-- 光环所有者
	self._auramodList = {}				-- 所有效果的最终值
	for i=1,AuraMod.max do
		self._auramodList[i] = { base=0, pct=0 }
	end
	self._auraRace = {}
	for i=0,AuraMod.max do
		self._auraRace[i] = {}
		for j=0,AuraRace.max do
			self._auraRace[i][j] = {base = 0,pct = 0}-- 检查是否同族
		end
	end
	self._triggerList = {}
	self._triggerList[AuraTriggerType.max]={}
end

function AuraMgr:getModValue(mod)
	return clone(self._auramodList[mod])
end

function AuraMgr:hasAura(id)
	for k,v in pairs(self._auraList) do
		if v.id == id then
			return true
		end
	end
	return false
end

function AuraMgr:hasAuraMod(mod)
	if self._auramodList[mod] then
		return self._auramodList[mod].base ~= 0 or self._auramodList[mod].pct ~= 0 
	else
		return false
	end
end

function AuraMgr:addAura( caster,spellEffect,displayId)
	assert(caster)
	assert(spellEffect)
	local mod = spellEffect.aura[0].mod
	local race = spellEffect.aura[0].race
	-- 检查是否有重复光环
	if self._auraRace[mod][race].base == 0 and
	 self._auraRace[mod][race].pct == 0  then

	 	-- 不存在RACE
	 	local newaura = Aura.new(caster,spellEffect,displayId)
		table.insert(self._auraList,newaura)
		self:applyAura(newaura)

	elseif self._auraRace[mod][race].base == base and
		self._auraRace[mod][race].pct == pct then
		-- 存在完全一样的RACE和值,重置持续时间
		aura:durationReset()
	else
		-- 不管效果是不是比现在好,反正不给加
		cclog("WARNING:AuraMgr:addAura failed, aura already exist!")
	end
end

function AuraMgr:applyAura(aura)
	aura:onAdd()
	local mod = aura:GetMod()
	if mod ~= AuraMod.none then
		self:_applyMod(aura)
	end
	if aura:isTrigger() then
		self:regTrigger(aura:GetTriggerType(),aura)
	end
end

function AuraMgr:unapplyAura(aura)
	aura:onRemove()
	if aura:GetMod() ~= AuraMod.none then
		self:_unapplyMod(aura)
	end
	if aura:isTrigger() then
		self:unregTrigger(aura:GetTriggerType(),aura)
	end
end

function AuraMgr:_applyMod(aura)
	local mod = aura:GetMod()
	local base = aura:GetBase()
	local pct = aura:GetPct()
	local race = aura:GetRace()
	cclog("AuraMgr:_applyMod,auraid:"..mod)

	assert(mod>AuraMod.none and mod<=AuraMod.max)
	assert(race>0 and race<=AuraRace.max)

	self._auramodList[mod].base = self._auramodList[mod].base + base
	self._auramodList[mod].pct = self._auramodList[mod].pct + pct

	self._auraRace[mod][race].base = base
	self._auraRace[mod][race].pct = pct
end

function AuraMgr:_unapplyMod(aura)
	if aura:GetMod() == AuraMod.none then
		return
	end

	local mod = aura:GetMod()
	local base = aura:GetBase()
	local pct = aura:GetPct()
	local race = aura:GetRace()
	cclog("AuraMgr:_applyMod,auraid:"..mod)

	assert(mod>AuraMod.none and mod<=AuraMod.max)
	assert(race>0 and race<=AuraRace.max)

	self._auramodList[mod].base = self._auramodList[mod].base - base
	self._auramodList[mod].pct = self._auramodList[mod].pct - pct
	
	self._auraRace[mod][race].base = 0
	self._auraRace[mod][race].pct = 0
end

function AuraMgr:update(dt)
	local removeList = {}
	for k,v in pairs(self._auraList) do
		local aura = v
		local mod = aura:GetMod()
		local duration = aura:GetDuration()
		local amplitude = aura:GetAmplitude()
		local period = aura:GetPeriod()

		if not aura:permanent()  then
			aura:durationPass(dt)
		end

		if duration <= 0 then
			removeList[#removeList + 1] = k	
		else
			local b = aura:update(dt)
			if b == false then
				removeList[#removeList + 1] = k	
			end
		end
	end

	for i = 1,#removeList do
		self:removeAura(removeList[i],self._auraList[removeList[i]])
 	end
end

function AuraMgr:removeAura(index,aura)
	if aura then
		self:unapplyAura(aura)
	end
	self._auraList[index] = nil
end

function AuraMgr:RemoveAuraByMod( mod )
	for k,aura in pairs(self._auraList) do
		if aura:GetMod() == mod then
			cclog("RemoveAuraByMod,mod id:"..mod)
			aura:SetDuration(0)
		end
	end
end

function AuraMgr:regTrigger(type,aura)
	assert(aura)
	assert(type>AuraTriggerType.none and type<AuraTriggerType.max)
	if not self._triggerList[type] then self._triggerList[type] = {} end
	self._triggerList[type][aura] = true
end

function AuraMgr:unregTrigger(type,aura)
	assert(aura)
	assert(type>AuraTriggerType.none and type<AuraTriggerType.max)
	self._triggerList[type][aura] = nil
end

function AuraMgr:getAuras(mod)
	local res = {}
	for k,aura in pairs(self._auraList) do
		if aura:GetMod() == mod then
			res[#res+1] = aura
		end
	end

	return res
end

-- 命中时触发
function AuraMgr:triggerOnHit()
	local l = self._triggerList[AuraTriggerType.onhit]
	if l then
		for k,v in pairs(l) do
			k:onTrigger()
		end
	end
end

function AuraMgr:triggerImpact()
	local l = self._triggerList[AuraTriggerType.impact]
	if l then
		for k,v in pairs(l) do
			k:onTrigger()
		end
	end
end

return AuraMgr

