-- phymod
local PHY = require "Common.phy"
local phymod_fly = class("phymod_fly")

ModPhase = {none=0,hit=1,up=2,down=3,floor=4}

function phymod_fly:ctor()
	self._phase = ModPhase.none
	self:reset()
end

function phymod_fly:reset()
	--[[
	击中阶段:命中后,如可以飞起,则被命中,然后准备飞
	如果已经在飞起,并且可以飞起,重新挨打,然后飞
	]]
	self._v0 = {x=0,y=0}
	self._a = {x=0,y=0}


	self._endTime = 0
	self._running = false

	self._t = 0				-- 全局时间记录
	self._g = 0 			-- 重力G常数

	self._pos = {x=0,y=0}	-- 源位置
	self._outPos= {x=0,y=0}	-- 输出位置

	self._basePos = {x=0,y=0}   -- 多次击打后,累加计算的基础位置
	self._currLoopPos = {x=0,y=0} -- 这一轮抛物线的位置
	self._currLoopTime = 0
	self._MaxS_T = 0		-- 这一轮到达最高点的时间
	self._Total_T =0 		-- 这一轮到达原始点的时间

	self._dropTime = 0
	self._dropPos = {x=0,y=0} -- 从最高点落下的位置
	self._dropMaxTime = 0
	self._dropMaxS = 0
end

function phymod_fly:running()
	return self._running
end

function phymod_fly:getPhase()
	return self._phase
end

function phymod_fly:getOutPos()
	return self._outPos
end
function phymod_fly:setStartPos(pos)
	self._pos = pos
end
function phymod_fly:setInitialValue(vx0,vy0,ax,ay)
	self._v0.x = vx0
	self._v0.y = vy0
	self._a.x = ax
	self._a.y = ay
end

function phymod_fly:start()
	self._running = true
end

function phymod_fly:stop()
	self._running = false
end

function phymod_fly:update(dt)
	if self._running then 
		self._t = self._t + dt
		self._currLoopTime = self._currLoopTime + dt

		if self._phase == ModPhase.up then
			self._currLoopPos.x = PHY:calcS(self._v0.x,self._a.x,self._currLoopTime)
			self._currLoopPos.y = PHY:calcS(self._v0.y,self._a.y,self._currLoopTime)

			self._outPos.x = self._pos.x + self._basePos.x + self._currLoopPos.x 
			self._outPos.y = self._pos.y + self._basePos.y + self._currLoopPos.y

			if self._currLoopTime >= self._MaxS_T then 
				self._phase = ModPhase.down 
				self._dropPos.x  = self._outPos.x
				self._dropPos.y  = self._outPos.y
			end

		elseif self._phase == ModPhase.down then
			self._dropTime  = self._dropTime  + dt

			self._outPos.x = self._dropPos.x + PHY:calcS(self._v0.x,self._a.x,self._dropTime)
			self._outPos.y = self._dropPos.y + PHY:calcS(0,self._a.y,self._dropTime)
--[[
只要差1帧就会差几十像素
			if self._dropTime <= self._dropMaxTime  then 
				self._phase = ModPhase.floor
			end 
]]
			if self._outPos.y <= self._pos.y then 
				self._outPos.y = self._pos.y
				self._phase = ModPhase.floor
			end 
			--cclog("droppos:%f %f  %f",dt,self._dropPos.y,self._outPos.y)
		end
	end

	
end

function phymod_fly:force( vx0,vy0,ax,ay )
	if self._phase == ModPhase.none then 
		self:setInitialValue( vx0,vy0,ax,ay )
		self._phase = ModPhase.up

		self._MaxS_T = PHY:calcMaxS_T(self._v0.y,self._a.y)
		self._Total_T = PHY:calcTotal_T(self._v0.y,self._a.y)
		self:start()

		self._endTime  = self._MaxS_T 

		self._dropMaxS = PHY:calcMaxS(self._v0.y,self._a.y)
	else
		self:setInitialValue( vx0,vy0,ax,ay )
		self._phase = ModPhase.up

		self._basePos.x = self._basePos.x + self._currLoopPos.x 
		self._basePos.y = self._basePos.y + self._currLoopPos.y 
		self._currLoopTime = 0

		self._MaxS_T = PHY:calcMaxS_T(self._v0.y,self._a.y)
		self._Total_T = PHY:calcTotal_T(self._v0.y,self._a.y)
		self:start()

		-- 计算总掉落时间
		self._dropMaxS = self._basePos.y +  PHY:calcMaxS(vy0,ay)
		self._dropMaxTime =  PHY:calcFreeFallT(self._dropMaxS,ay)
		self._endTime  = self._t + self._MaxS_T + self._dropMaxTime

		--cclog("第一次到达高度:%d",self._basePos.y )
		--cclog("第二次到达高度:%d",PHY:calcMaxS(vy0,ay) )
		--cclog("第二次到达总高度:%d",self._dropMaxS  )
		--cclog("第二次加速度:%d",ay)
		--cclog("掉落时间:%f",self._dropMaxTime)

		--cclog("FORCE %d %f %f %f",self._dropMaxS, self._dropMaxTime, self._t,self._MaxS_T)
		
	end 

	
end

return phymod_fly