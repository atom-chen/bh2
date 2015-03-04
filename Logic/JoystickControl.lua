local JoystickControl = class("JoystickControl", BaseControl)
JoystickControl.__index = JoystickControl

local function circleContainsPoint(circleRadius,pt,circlecenterPt)
	local dist = cc.pGetDistance(pt,circlecenterPt)
	if circleRadius >= dist then
		return true
	else
		return false
	end
end

-- 求两点的夹角（弧度）
local function radians4point(ax, ay, bx, by)
    return math.atan2(ay - by, bx - ax)
end

-- 求圆上一个点的位置
local function pointAtCircle(px, py, radians, radius)
    return px + math.cos(radians) * radius, py - math.sin(radians) * radius
end

function JoystickControl:ctor()
	self.super.ctor(self)
end

function JoystickControl:initControlUI()
	self._dir = cc.p(0,0)
	self.touchRect = cc.rect(0,0,480,640)
	self._touchCircleRadius = sMiscValueInfo[miscValue.stickRaduis].value
	self._touchCircleCenter = cc.p(0,0)
	self._clickMeleeBtnTime = 0

	local image = self._ui:getChild("joystick_bg")
	image:setVisible(true)
	self._touchCircleCenter = image:pos()
	local stick = self._ui:getChild("joystick")
	stick:setVisible(true)
	self._ctrlType = nil
	self._key = cc.p(0,0)

	self._stick = 
	{
		node = stick,
		orgPos = stick:pos(),
		radius = pix(50),
	}


	local attkBtn = self._ui:getChild("battle_gongji")
	attkBtn:setVisible(true)
	attkBtn:setTouchEnabled(true)
	attkBtn:addTouchEvent({[ccui.TouchEventType.began] = handler(self,self.onClick),
						   [ccui.TouchEventType.ended] = handler(self,self.onClickAttk)
						})
end

function JoystickControl:releaseControlUI()
	self._ui:getChild("battle_gongji"):setTouchEnabled(false)
	self._ui:getChild("battle_gongji"):setVisible(false)
	self._ui:getChild("joystick_bg"):setVisible(false)
	self._ui:getChild("joystick"):setVisible(false)
end

function JoystickControl:moveStick(m_pos)
	if self._ctrlType == keyBoardType then
		return 
	end
	self._ctrlType = stickType
	--local m_pos = uiwidget:getTouchMovePosition()
	local orgPos = self._stick.orgPos
	local radius = self._stick.radius
	local node = self._stick.node
	local pos = m_pos
	node:pos(pos)

	local dir = cc.pNormalize(cc.pSub(pos,orgPos))
	cclog("dir x:"..dir.x.. " y:"..dir.y)
	self._controller:setDir(dir)
	self._controller:move()

	self._dir = dir
end

function JoystickControl:releaseStick()
	if self._ctrlType == keyBoardType then
		return 
	end
	self._ctrlType = nil
	local node = self._stick.node
	local orgPos = self._stick.orgPos
	local dir = self._controller:dir()
	dir.y = 0
	self._controller:setDir(dir)
	node:pos(orgPos)
	self._controller:stand()

	self._dir = cc.p(0,0)
end

function JoystickControl:ClickOn(pt)
	--if cc.rectContainsPoint(self.touchRect,pt) == false then return end
	if circleContainsPoint(self._touchCircleRadius,pt,self._touchCircleCenter) == false then 
		return 
	end
	self:moveStick(pt)
end

function JoystickControl:drag(pt)
	if pt.x < 0 then pt.x = 0 end
	if pt.y < 0 then pt.y = 0 end
	local pos = pt
	if circleContainsPoint(self._touchCircleRadius,pt,self._touchCircleCenter) == false then
		local radian = radians4point(self._touchCircleCenter.x,self._touchCircleCenter.y,pt.x,pt.y)
		pos.x,pos.y = pointAtCircle(self._touchCircleCenter.x,self._touchCircleCenter.y,radian,self._touchCircleRadius)
	end
	self:moveStick(pos)
end

function JoystickControl:ClickEnd(pt)
	self:releaseStick()
end

function JoystickControl:onClick(uiwidget)
	self._clickMeleeBtnTime = 0
end

function JoystickControl:onClickAttk(uiwidget)
	if self._clickMeleeBtnTime <= sMiscValueInfo[miscValue.clickMeeleBtnTime].value then
		if self._controller:attack() then
			if math.abs(self._dir.x) >= 0.9 then
				cclog("player向攻击方向滑行一小段距离")
				self._controller:slideWhenAttack()
			end
		end
	end
	self._clickMeleeBtnTime = 0
end

function JoystickControl:update(dt)
	self:updateClickBtnTime(dt)
	self:updateControllerMove(dt)
end

function JoystickControl:updateClickBtnTime(dt)
	self._clickMeleeBtnTime = self._clickMeleeBtnTime + dt
end

function JoystickControl:updateControllerMove( dt )
	local player = self._controller
	if player:hasState(state.move) == false or not player:canMove() then
		return
	end
	
	local pos = player:pos()
	local movePos = {}
	local dir = player:dir()
	local speed = player:speed()
	movePos.x = pos.x - speed.x * dt * dir.x
	movePos.y = pos.y - speed.y * dt * dir.y
	if player._map:GetSpeed() ~= speed then
		player._map:SetSpeed(speed)
	end

	local function checkPos( pos )
		if pos.x < 0 then
			pos.x = 0
		elseif pos.x > player._map._lockRect.width then
			pos.x = player._map._lockRect.width
		end
		if pos.y < 0 then
			pos.y = 0
		elseif pos.y > player._map._lockRect.height then
			pos.y = player._map._lockRect.height
		end
	end
	checkPos(pos)
	checkPos(movePos)

	local function adjustPos( pos,movePos )
		if pos.x >= winSize.width/2 and pos.x <= player._map._lockRect.width - winSize.width/2 then
			--direction>0:向右移动，<0：向左移动
			if dir.x > 0 then 
				if player._map:isRBorder() then
					--cclog("人物往右走，地图到了右边缘")
				else
					--人物往右走，如果地图没到右边缘，移动地图
					--cclog("---人物往右走，如果地图没到右边缘，移动地图")
					player._map:updateMove(dt,dir)
				end
			else
				if player._map:isLBorder() then
					--cclog("地图已经移动到最左")
				else
					--cclog("---向右移动地图")
					--人物往左走，如果地图没到左边缘，移动地图
					player._map:updateMove(dt,dir)
				end
			end
		elseif pos.x < winSize.width/2 then

		elseif pos.x > player._map._lockRect.width - winSize.width/2 then
			if dir.x > 0 then 
				if player._map:isRBorder() then
					--cclog("人物往右走，地图到了右边缘")
				else
					--人物往右走，如果地图没到右边缘，移动地图
					--cclog("---人物往右走，如果地图没到右边缘，移动地图")
					player._map:updateMove(dt,dir)
				end
			else
				
			end

		else
			assert(false)
		end
	end


	adjustPos(pos,movePos)
end

return JoystickControl