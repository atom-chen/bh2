--CameraMgr.lua
local CameraMgr = class("CameraMgr")
CameraMgr.__index = CameraMgr


local CameraState =
{
	normal = 0,
	reaction = 1,	-- 反应延迟
	upmove = 2,		-- 加速移动状态(按下按钮)
	downmove = 3,	-- 减速移动状态(松开按钮)
}

function CameraMgr:ctor()
	self._map = nil
end


function CameraMgr:init(map)
	self._map = map

	self._state = CameraState.normal

	self.vmin = 0	-- 	启动速度
	self.vmax = 0	-- 最高速度
	self.upa = 0	-- 当前加速度
	self.downa = 0 -- 当前加速度
	self.dir = 0	-- 移动方向
	self.enddir = 0	-- 结束时方向
	self.endpos = 0	-- 结束时位置
	self.endtouch = false

	-- 地图常数
	self.rightstartpos = 30
	self.leftstartpos = 75


	self.rightendpos = 45
	self.leftendpos = 55

	-- 点击按下后的反应延迟
	self.reactionDelay = 0
	self.timerReaction = 0


	-- 位置记录
	self.v0 = 0  --当前初速度

	--主角位置
	--主角方向
	
	-- 地图段边缘
	self.partleft = 0
	self.partright = 960

	-- 地图最大边缘X
	-- 地图最大边缘Y
	self.sectionleft = 0
	self.sectionright = 1920

	self.free = false

end

function CameraMgr:setFree(bfree)
	self.free = true
end

function CameraMgr:setPartLimit(left,right)
	self.partleft = left
	self.partright = right
end

function CameraMgr:setSectionLimit(left,right)
	self.sectionleft = left
	self.sectionright = right
end

function  CameraMgr:startmove(dir)
	--local dir = self._map:getPlayer(1):getFace()
	--if self:reachMove(dir) then
		local vmax = self._map:getPlayer(1):speed().x
		self:_startmove(50,vmax,150,500,dir)
	--end
end

function  CameraMgr:endmove()
	self.endtouch = true
end

function  CameraMgr:_startmove(vmin, vmax,upa,downa,dir)
	--if self._state == CameraState.normal then
		self._state = CameraState.reaction

		self.vmin = vmin
		self.vmax = vmax
		self.dir = dir
		self.upa = upa
		self.downa = downa
		--cclog("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!dir:"..self.dir)
	--end
end

function  CameraMgr:_endmove()
	if	self.endtouch == true then
		self._state = CameraState.downmove
		self.v0 = 500
		self.enddir = self._map:getPlayer(1):getFace()
		local pos = self._map:getPlayer(1):getScreenPos()
		self.endpos = pos.x*100 / winSize.width
		self.endtouch = false
	end
end



function CameraMgr:update(dt)
	-- 处理反应延迟
	if self._state == CameraState.reaction then
		self.timerReaction = self.timerReaction + dt
		if self.timerReaction>=self.reactionDelay then
			self._state = CameraState.upmove
			self.timerReaction = 0
		end
	end

	-- 处理是否已经抬起了手指
	if self.endtouch == true then
		self:_endmove()
	end

	--cclog("dir:"..self.dir)
	-- 处理移动
	--local pos = self._map:getPlayer(1):getScreenPos()
	--pos.x*100 / winSize.width >= self.rightendpos


	if self._state == CameraState.upmove  then
		self:_upmove(dt)
	end

	if self._state == CameraState.downmove then
		self:_downmove(dt)
	end

end


function CameraMgr:_upmove(dt)
	--[[
	 是否开始移动
	]]
	-- 如果没有到达移动区域
	if not self:reachMove(self.dir) then
		s = 0
		return
	end
	--[[
	 这一帧的位移s = v0 * dt + a * dt *dt
	 这一帧完成后下一帧起始的 vt = v0 + a*dt

	 如果这一帧超过最高速度,则使用V0保持匀速直线运动
	]]

	local s = 0 -- 这一帧的位移
	if self.v0 >=  self.vmax then  -- 保持匀速直线运动
		s = self.v0 * dt
	else
		s = self.v0 * dt + self.upa * dt * dt 
		self.v0 = self.v0 + self.upa * dt
	end

	self._map._uiLayer:addLabel2("upmove::s:"..s.." state:"..self._state)
	
	-- 如果当前位置超过地图边缘,进行裁剪
	s = self:_clipX(s)

	-- 进行地图移动
	s = s * self.dir

	self._map._uiLayer:addLabel3("upmove::s:"..s.." state:"..self._state)
	
	self._map:CameraMove(s)
end

function CameraMgr:_clipX(s)
	if s == 0 then
		return s
	end 

	local xmax = 0
	local xmin = 0
	if self.free then
		xmin = self.sectionleft
		xmax = self.sectionright
	else
		xmin = self.partleft
		xmax = self.partright
	end
	
	self._map._uiLayer:addLabel4("_clipX1:dir"..self.dir.." state:"..self._state.. " s:"..s.."camerax:"..self._map:CameraX().."xmax:"..xmax.."xmin:"..xmin)
	
	if self.dir == faceright then 
		if self._map:CameraX() + s + winSize.width - xmax > 1 then

			self._map._uiLayer:addLabel5("_clipX2:s:"..s.."camerax:"..self._map:CameraX().."xmax:"..xmax.."xmin:"..xmin)
			s = xmax - self._map:CameraX() - winSize.width
			self._map._uiLayer:addLabel6("_clipX3:s:"..s.."camerax:"..self._map:CameraX().."xmax:"..xmax.."xmin:"..xmin)

			if s<0 then
				s=0
			end
		end
	else
		if xmin - (self._map:CameraX() - s) >1  then
			self._map._uiLayer:addLabel7("_clipX4:dir"..self.dir.." s:"..s.."camerax:"..self._map:CameraX().."xmax:"..xmax.."xmin:"..xmin)
			s = self._map:CameraX() - xmin
			self._map._uiLayer:addLabel8("_clipX5:dir"..self.dir.." s:"..s.."camerax:"..self._map:CameraX().."xmax:"..xmax.."xmin:"..xmin)

			if s<0 then
				s=0
			end
		end
	end

	--self._map._uiLayer:addLabel7("_clipX4:s:"..s.."camerax:"..self._map:CameraX().."xmax:"..xmax.."xmin:"..xmin)

	return s
end

function CameraMgr:canMoveRight()
	local xmax = 0
	local xmin = 0
	if self.free then
		xmin = self.sectionleft
		xmax = self.sectionright
	else
		xmin = self.partleft
		xmax = self.partright
	end

	if self._map:CameraX() + winSize.width >= xmax then
		return false
	end

	return true
end

function CameraMgr:canMoveLeft()
	local xmax = 0
	local xmin = 0
	if self.free then
		xmin = self.sectionleft
		xmax = self.sectionright
	else
		xmin = self.partleft
		xmax = self.partright
	end

	if self._map:CameraX() <= xmin then
		return false
	end

	return true
end

function CameraMgr:reachMoveRight()
	if self:canMoveRight() and  
		self:getHeroPos() - self.rightstartpos > 4 then
		return true
	end

	return false
end

function CameraMgr:reachMoveLeft()
	if self:canMoveLeft() and  
		 self.leftstartpos - self:getHeroPos() > 4 then
		return true
	end

	--cclog("555555555")
	return false
end

function CameraMgr:reachMove(dir)

	if dir == faceright and self:reachMoveRight() then
		return true
	elseif dir == faceleft and self:reachMoveLeft() then
		return true
	end

	
	return false
end

function CameraMgr:canMove()

end

function CameraMgr:getHeroPos()
	local pos = self._map:getPlayer(1):getScreenPos()
	local x = math.abs(pos.x*100 / winSize.width)
	return x
end


function CameraMgr:_downmove(dt)
	--[[
	判断应该回到什么位置
	停止时

	如果主角面向右边
		如果主角位置不到45%,则不动
		如果主角位置到45%,则动,停下时,必然大于45%,屏幕向右回到45%
		如果主角位置超过50%,则动,停下时,必然大于45%,屏幕向右回到45%
	如果主角面向左边
		如果主角位置不到45%,则不动
		如果主角位置到45%,则动,停下时,回到45%
		如果主角位置到45%,则动,停下时,回到45%
	]]
	-- 结束判定
	-- 如果
	local pos = self._map:getPlayer(1):getScreenPos()
	self.endpos = math.abs(pos.x*100 / winSize.width)

	self._map._uiLayer:addLabel1("self.enddir:"..self.enddir.. " screen:"..pos.x..",end:"..self.endpos.." v0:".. self.v0)

	if self.enddir == faceright and 
		(self.endpos < self.rightendpos or self:canMoveRight()==false )then
			s=0
			self._state = CameraState.normal
			return
	end

	if self.enddir == faceleft and
		(self.endpos > self.leftendpos or self:canMoveLeft()==false )then
			s=0
			self._state = CameraState.normal
			return
	end

	-- 计算这一帧的移动位移
	local s = self.v0 * dt -- + self.downa * dt * dt 
	--self.v0 = self.v0 + self.downa * dt
	if s <= 0 then
		s = 0
	end
	--[[
	如果已经到达最高速度,则减速
	如果未到最高速度,也减速
	]]

	-- 如果当前位置超过地图边缘,进行裁剪
	s = self:_clipX(s)

	-- 进行地图移动
	s = s * self.dir
	self._map:CameraMove(s)
end


return CameraMgr