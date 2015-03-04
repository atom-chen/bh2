--[[
class MotionTarget
]]
local  MotionTarget = class("MotionTarget",require "AI.Motion")
MotionTarget.__index = MotionTarget

function MotionTarget:ctor(type,pl)
	self.super.ctor(self,type,pl)
--	self._type = type
--	self._player = pl
end

function MotionTarget:SetTargetPos(pos,speed)
	self._targetX = pos.x
	self._targetY = pos.y
	self._speed = speed
	self._complate = false
end

function MotionTarget:start()
	self._player:goto(cc.p(self._targetX,self._targetY ),self._speed,handler(self,self.arrive) )
end

function MotionTarget:stop()
end

function MotionTarget:arrive()
	self._complate = true
end

function MotionTarget:complate()
	return self._complate;
end


return MotionTarget