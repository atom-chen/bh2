local Spell = require("Spell.Spell")
local SpellMgr = class("SpellMgr")
SpellMgr.__index = SpellMgr

local err = 
{
	ok			= 0,
	cost_hp		= 1,
	cost_mp		= 2,
	interrupt 	= 3,
	cooling 	= 4,
}

local errStr = 
{
	"hp不足",
	"mp不足",
	"被打断",
	"冷却中",
}

function SpellMgr:ctor(caster)
	self._caster = caster
	self._instances = {}
	self._finish = {}
	self._CoolDown = {}
	self._err = {}
	for _,code in pairs(err) do
		if code ~= 0 then
			self._err[code] = {}
		end
	end
end

function SpellMgr:addSpell(id)
	-- 首先判断技能是否在cd
	local guid = 0
	if self:isCoolingOf(id) then
		self:addError(id,err.cooling)
		return
	end
	local spellEntry = sSpellEntry[id]
	if not spellEntry then return end
	if self:checkCost(self._caster,spellEntry) then
		local sp = nil
		if spellEntry then
			guid = #self._instances+1
		 	sp = Spell.new(self,spellEntry,guid)
		end
		if sp then
			sp:prepare()
			self._instances[guid] = sp
			--加入CD
			self._CoolDown[id] = spellEntry.cooldown/1000
		end
	end
	return guid
end

function SpellMgr:isCoolingOf(id)
	if self._CoolDown[id] then
		return self._CoolDown[id] ~= 0
	else
		return false
	end
end

function SpellMgr:checkCost(caster,spellEntry)
	local ret = false
	local info = spellEntry
	if caster then
		local cost = info.cost or 0
		if info.costType == 1 then
			local mp = caster:getMp()
			if mp < cost then
				self:addError(info.id,err.cost_mp)
				return ret
			end
		elseif info.costType == 2 then
			local hp = caster:getHp()
			if hp <= cost then
				self:addError(info.id,err.cost_hp)
				return ret
			end
		end
		ret = true
	end
	return ret
end

function SpellMgr:cancelSpell(guid)
	local spell = self._instances[guid]
	if spell then
		spell:cancel()
		self:addError(spell._info.id,err.interrupt)
	end
end

function SpellMgr:addError(id,err)
	table.insert(self._err[err],id)
end

function SpellMgr:SendResult(id,err)
	local spellEntry = sSpellEntry[id]
	cclog("技能:[%s] 施放失效,原因:%s",spellEntry.name,errStr[err])
	self._caster:SpellResult(id,err)
end

function SpellMgr:update(dt)
	-- 首先更新CoolDownTime
	self:updateCD(dt)

	-- 更新spell
	for _,spell in pairs(self._instances) do
		spell:update(dt)
	end

	-- 结束spell
	for guid,_ in pairs(self._finish) do
		self._instances[guid] = nil
	end

	self._finish = {}

	-- 发送异常结果
	for code,v in pairs(self._err) do
		for _,id in ipairs(v) do
			self:SendResult(id,code)
		end
		self._err[code] = {}
	end
end

function SpellMgr:updateCD(dt)
	for id,v in pairs(self._CoolDown) do
		local cd = v
		cd = cd - dt
		if cd < 0 then
			cd = 0
		end
		self._CoolDown[id] = cd
	end
end

function SpellMgr:FinishSpell(guid)
	self._finish[guid] = true
end 

return SpellMgr