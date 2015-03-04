local Unit = require 'Object.Unit'
local Creature = class("Creature",Unit)
Creature.__index = Creature


function Creature:ctor(info)
	Unit.ctor(self,info,MonsterType)
end

function Creature:addToWorld(map,pos,face,ai)
	self:setHp(50)
	self:setMap(map)
	self:setPos(pos)
	self:setAI(ai)
	self:setDir(cc.p(face,0))
	self._face=face
	self._map:addSceneObject(self)
	--self._schedule = sharedDirector:getScheduler():scheduleScriptFunc(handler(self,self._update),0,false)

	self._hpbar = require("utils.ValueStrip").new()
	self._hpbar:setVisible(false)
	self._hpbar:pos(cc.p( 0,self._actor._armature:pos().y + self._actor._armature:getBoundingBox().height + 15))
	self._actor:addChild(self._hpbar)
	self._addToWorld = true
end

function Creature:UpdateHpBar( per )
	if per > 0 then
		self._hpbar:pos(cc.p( 0,self._actor._armature:pos().y + self._actor._armature:getBoundingBox().height + 15))
		self._hpbar:changeValue(1,per)
	end
end

return Creature