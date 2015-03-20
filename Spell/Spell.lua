local function getSelf(caster,...)
	local t = {}
	t[caster] = false
	return t
end

local function getTargets(caster,type,targets)
	local condition = function(target)
 		return target:isAlive() and target:isInWorld()
	end
	return caster:getHostile(condition,targets)
end

local function getAreaTargets(caster,type,targets)
	assert(false)
	return {}
end

local fillTargetFunc = 
{
	[0] = getTargets,
	[1] = getSelf,
	[2] = getAreaTargets,
}


local Effect = require 'Spell.Effect'
local SpellDisplay = require 'Spell.SpellDisplay'

local prepare = 0
local start = 1
local waiting = 2
local running = 3
local finish = 4

local Spell = class("Spell")
Spell.__index = Spell

function Spell:ctor(mgr,info,guid)
	self._mgr = mgr
	self._guid = guid
	self._caster = mgr._caster 		-- 施放者
	self._info = info
	self._state = prepare
	self._targets = {}
	self._display = nil
	self._damage = 0
	self._effects = {}	-- 效果实例
	self._curMove = nil
	self._tag = {}		-- 触发了的标签
	self._defaultEffect = nil
end

-----------------------------------------------------
-- public function 								   --
-----------------------------------------------------
function Spell:prepare()
	local displayId = self._info.displayID
	local entry = sSpellDisplayStore[displayId]
	local anim = entry.action
	local loop = entry.loop == 1
	if anim and anim ~= "" then
		self._caster:ActorPlay(anim,loop)
	end
--	uber.TimingBegin()
	self:createDisplay()
--	uber.TimingEnd("createDisplay")
end

function Spell:cancel()
	local displayId = self._info.displayID
	local entry = sSpellDisplayStore[displayId]
	local anim = entry.action
	self._caster._actor:setCallBack(anim,nil,sp.EventType.ANIMATION_END)
	self:finish()
end

function Spell:start()
	self._state = start
end

function Spell:finish()
	self._state = finish
end

function Spell:Started()
	return self._state == start
end

function Spell:Finished()
	return self._state == finish
end

function Spell:Running()
	return self._state == running
end

function Spell:update(dt)

	if self:Started() then
		self:onStart()
	end

	if self:Running() then
		self:fillTargets()
		self:ApplyEffects()
		--self:checkFinish()
		--self:drawBound()
	end

	if self:Finished() then
		self:onFinish()
	end

end

-----------------------------------------------------
-- private function 							   --
-----------------------------------------------------
function Spell:createDisplay()
	local displayEntry = sSpellDisplayStore[self._info.displayID]
	self._display = SpellDisplay.new(displayEntry.cast,self)
	self._display:onAdd(self._caster)
end

function Spell:onStart()
	for _,idx in pairs(self._info.effect) do
		if idx ~= 0 then
			local effect = Effect.new(self,idx)
			self._effects[effect] = {}
			if effect:isTagTigger() then
				if not self._defaultEffect then
					self._defaultEffect = idx
				end
				self._effects[effect] = nil
			end
		end
	end
	self._state = running
end

function Spell:onFinish()
	if self._display then
		self._display:onRemove()
	end
	self._mgr:FinishSpell(self._guid)
	self._caster:finishSpell(self._guid)
	--self:removeBound()
end

function Spell:onTag_(name)
	if not self._tag[name] then
		self:startTag(name)
	else
		self:endTag(name)
	end
end

function Spell:startTag(name)
	local effect = self:createEffect(name)
	effect = effect or Effect.new(self,self._defaultEffect)
	effect:On()
	self._effects[effect] = {}
	self._tag[name] = effect
end

function Spell:endTag(name)
	--self._effects = {}
	--self._targets = {}
	--self._state = waiting
	local effect = self._tag[name]
	effect:Off()
	self._effects[effect] = nil
	self._tag[name] = nil
end

function Spell:checkRange(target)
	--return false
	
	local area = self:getBox()
	local z = self:getZ()
	local box = target:getBox()
	local z2 = target:getZ()
	z = math.abs(z - z2)/10
	z2 = self:getCollZ()
	--cclog("测试代码,没有填写collz默认设置为50")
	if z2 == 0 then z2 = 50 end
	if z <= z2 then
		return cc.rectIntersectsRect(area,box)
	else
		return false
	end
	
end

function Spell:getZ()
	local z = self._caster:getZ()
	return z
end

function Spell:getCollZ()
	if self._curMove then
		return self._curMove.collZ
	else
		return self._info.collZ
	end
end

function Spell:getBox()
	local move = self._curMove
	local area = cc.rect(0,0,0,0)
	if move and move.coll_data == 1 then
		area.x = move.collX
		area.y = move.collY
		area.width 	= move.collW
		area.height = move.collH
	else
		area = self._display:getBox()
	end
	return area
end

function Spell:fillTargets()
	local caster = self._caster
	for effect,_ in pairs(self._effects) do
		local targets = self._effects[effect]
		local idx = effect._info.target
		local targetType = effect._info.targetType
		self._effects[effect] = fillTargetFunc[idx](caster,targetType,targets)
	end
end

-- 实例effect
function Spell:createEffect(moveName)
	local move = SpellManager:getMove(moveName)
	local effect = nil
	if move then
		self._curMove = move
		local idx = move.effect
		effect = Effect.new(self,idx)
	end
	return effect
end

-- 应用effect
function Spell:ApplyEffects()
	local caster = self._caster
	for effect,targets in pairs(self._effects) do
		if effect:applied() == false then
			effect:apply(caster,targets)
		end
	end
end

-- 检查结束
function Spell:checkFinish()
	for effect,_ in pairs(self._effects) do
		if effect:applied() == false then
			return
		end
	end
	self:finish()
end

-- debug
local color = cc.c4f(0.0,1,1.0,1.0)

function Spell:drawBound()
	if not self._bound then
		self._bound = cc.DrawNode:create()
		self._caster._map:addChild(self._bound,999)
	end
	local rect = self:getBox()
	self._bound:clear()
	self._bound:drawRect(cc.p(rect.x,rect.y),cc.p(rect.x+rect.width,rect.height+rect.y),color)
end

function Spell:removeBound()
	self._logic._map:removeChild(self._bound)
	self._bound = nil
end
---

return Spell

