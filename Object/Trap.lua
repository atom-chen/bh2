local GameObject = require 'Object.GameObject'
local Effect = require 'Spell.Effect'
local Trap = class("Trap",GameObject)
Trap.__index = Trap

function Trap:ctor(guid,displayId,effect,caster)
	local info = sSpineStore[displayId]
	GameObject.ctor(self,guid,info,TrapType)
	self._effect = effect
	self._caster = caster
	self._targets = {}
	self._period = self._effect.aura[0].period > 0
	self:ActorPlay(info.animation,true,1)
end

function Trap:addToWorld(map,pos,face,ai)
	self:setMap(map)
	self:setPos(pos)
	self:setAI(ai)
	self:setDir(cc.p(face,0))
	self._face=face
	self._map:addSceneObject(self)
	self._addToWorld = true
	if self._period then
		self:addAura(self._effect,0)
	end
end

function Trap:updateVisableFor(pl)
	self._viewList[pl] = 0

	-- 如果是敌对的
	local caster = self:getOwner()
	if caster and caster:isHostileTo(pl) then
		self:getThreatMgr():add(pl)
	elseif not caster and pl:isPlayer() then
		self:getThreatMgr():add(pl)
	end

	-- 触发AI脚本
	if self._ai then
		self._ai:MoveInLineOfSight(pl)
	end
end

function Trap:getOwner()
	return self._caster
end

function Trap:update(dt)
	-- 判断是否有人触发了
	if not self._period then
		local threat = self:getThreatMgr():getAll()
		local tigger = false
		for unit,_ in pairs(threat) do
			if self:check(unit) then
				tigger = true
				self._targets[unit] = false
			end
		end 
		-- 根据陷阱类型来判断作用效果
		if tigger then
			local effect = Effect.new(nil,self._effect.id)
			effect:Instant(self._caster,self._targets)
		end

		self:FadeOut()
	else
		self:updateAura(dt)
		self:updateSpell(dt)
	end
end

function Trap:checkRange(target)
	local area = self:getBox()
	local z = self:getZ()
	local box = target:getBox()
	local z2 = target:getZ()
	z = math.abs(z - z2)/10
	z2 = 0--self:getCollZ()
	--cclog("测试代码,没有填写collz默认设置为50")
	if z2 == 0 then z2 = 50 end
	if z <= z2 then
		return cc.rectIntersectsRect(area,box)
	else
		return false
	end
end

return Trap
