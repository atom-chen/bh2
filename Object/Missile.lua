local GameObject = require 'Object.GameObject'
local Missile = class("Missile",GameObject)
Missile.__index = Missile

function Missile:ctor(displayId,spellId,caster)
	local info = sSpineStore[displayId]
	GameObject.ctor(self,info,MissileType)
	self._spellId = spellId -- 携带的技能
	self._caster = caster 	-- 释放者
	self._targets = {}
end

function Missile:addToWorld(map,pos,face,ai)
	self:setMap(map)
	self:setPos(pos)
	self:setAI(ai)				-- 加AI是为了自动制导?
	self:setDir(cc.p(face,0))
	self._face=face
	self._map:addSceneObject(self)
	self._addToWorld = true
	self:TriggerSpell(self._spellId)
end

function Missile:updateVisableFor(pl)
	self._viewList[pl] = 0

	-- 如果是敌对的
	if self:getOwner():isHostileTo(pl) then
		self:getThreatMgr():add(pl)
	end

	-- 触发AI脚本
	if self._ai then
		self._ai:MoveInLineOfSight(pl)
	end
end

function Missile:update(dt)
	self:updateAura(dt)
	self:updateSpell(dt)
	if self._ai then
		self._ai:update(dt)
		self._MotionMgr:update()
	end
	-- 移动?
	self:updateMove(dt)
	self:impact()
end

function Missile:getOwner()
	return self._caster
end

function Missile:impact()
	local threat = self:getThreatMgr():getAll()
	local yes = false
	for unit,_ in pairs(threat) do
		if self:check(unit) then
			yes = true
			self._targets[unit] = false
		end
	end 

	if yes then
		self._AuraMgr:triggerOnImpact()
	end
end

function Missile:getImpactTargets()
	return self._targets
end

function Missile:check(target)
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

return Missile