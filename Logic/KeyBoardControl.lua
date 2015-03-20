KeyBoardManager = require("Common.KeyBoardManager").new()
local KeyBoardControl = class("KeyBoardControl", BaseControl)
KeyBoardControl.__index = KeyBoardControl

local stickType = 1
local keyBoardType = 2

local key =
{
	right = BIT(0),
	left = 	BIT(1),
	up = 	BIT(2),
	down = 	BIT(3),
}

--testEvent = require("Event.testEvent")
require("Event.Manager")

function KeyBoardControl:ctor()
	self.super.ctor(self)
end

function KeyBoardControl:addState(state)
	self._keyState = bor(self._keyState,state)
	--cclog("player state :%x",self._state)
end

function KeyBoardControl:hasState(state)
	return band(self._keyState,state) > 0
end

function KeyBoardControl:removeState(state)
	self._keyState = band(self._keyState,bnot(state))
	--cclog("player state :%x",self._state)
end

function KeyBoardControl:initControlUI()
	self._dir = cc.p(0,0)
	self.touchRect = cc.rect(0,0,480,640)
	self._touchCircleRadius = sMiscValueInfo[miscValue.stickRaduis].value
	self._touchCircleCenter = cc.p(0,0)
	self._clickMeleeBtnTime = 0

	local image = self._ui:getResourceNode():getChild("joystick_bg")
	image:setVisible(true)
	self._touchCircleCenter = image:pos()
	local stick = self._ui:getResourceNode():getChild("joystick")
	stick:setVisible(true)
	self._ctrlType = nil
	self._key = cc.p(0,0)

	self._stick = 
	{
		node = stick,
		orgPos = stick:pos(),
		radius = pix(50),
	}

	self._keyState = 0

	local attkBtn = self._ui:getResourceNode():getChild("battle_gongji")
	attkBtn:setVisible(true)
	attkBtn:setTouchEnabled(true)
	attkBtn:addTouchEvent({[ccui.TouchEventType.began] = handler(self,self.onClick),
						   [ccui.TouchEventType.ended] = handler(self,self.onClickAttk)
						})

	local skill1 = self._ui:getResourceNode():getChild("btn_cg0")
	skill1:setVisible(true)
	skill1:setTouchEnabled(true)
	skill1:addTouchEvent({[ccui.TouchEventType.began] = handler(self,self.onCastSpell1)})

	local skill2 = self._ui:getResourceNode():getChild("btn_cg1")
	skill2:setVisible(true)
	skill2:setTouchEnabled(true)
	skill2:addTouchEvent({[ccui.TouchEventType.began] = handler(self,self.onCastSpell2)})

	local skill3 = self._ui:getResourceNode():getChild("btn_cg2")
	skill3:setVisible(true)
	skill3:setTouchEnabled(true)
	skill3:addTouchEvent({[ccui.TouchEventType.began] = handler(self,self.onCastSpell3)})

	local keyshortcut = KeyBoardManager:getShortcuts("KeyBoardControl")
	if not keyshortcut then
		keyshortcut = KeyShortcuts.new("KeyBoardControl")
		keyshortcut:add(single_type,"KEY_W",handler(self,self.onMoveUp),handler(self,self.onReleaseUp))
		keyshortcut:add(single_type,"KEY_A",handler(self,self.onMoveLeft),handler(self,self.onReleaseLeft))
		keyshortcut:add(single_type,"KEY_S",handler(self,self.onMoveDown),handler(self,self.onReleaseDown))
		keyshortcut:add(single_type,"KEY_D",handler(self,self.onMoveRight),handler(self,self.onReleaseRight))
		keyshortcut:add(single_type,"KEY_J",handler(self,self.onClick),handler(self,self.onClickAttk))
		keyshortcut:add(single_type,"KEY_K",handler(self,self.onCastSpell1),nil)
		keyshortcut:add(single_type,"KEY_U",handler(self,self.onCastSpell2),nil)
		keyshortcut:add(single_type,"KEY_I",handler(self,self.onCastSpell3),nil)
		KeyBoardManager:add(keyshortcut)
	end
	KeyBoardManager:apply("KeyBoardControl")
	--[[
	local circle = display.newCircle(self._touchCircleRadius,
        {x = self._touchCircleCenter.x, y = self._touchCircleCenter.y,
        fillColor = cc.c4f(1, 0, 0, 0),
        borderColor = cc.c4f(0, 1, 0, 1),
        borderWidth = 2})
	self._ui:addChild(circle)]]
end

function KeyBoardControl:releaseControlUI()
	self._ui:getChild("battle_gongji"):setTouchEnabled(false)
	self._ui:getChild("battle_gongji"):setVisible(false)
	self._ui:getChild("joystick_bg"):setVisible(false)
	self._ui:getChild("joystick"):setVisible(false)
end

function KeyBoardControl:onMoveUp()
	if self._ctrlType == stickType then
		return
	end
	self._ctrlType = keyBoardType
	self._key.y = 1.0
	self:addState(key.up)
	self:StickPos()

	self._dir = cc.p(0,1)
	self._canCastSpell3 = false
end

function KeyBoardControl:onMoveLeft()
	if self._ctrlType == stickType then
		return
	end
	self._ctrlType = keyBoardType
	self._key.x = -1.0
	self:addState(key.left)
	self:StickPos()

	self._dir = cc.p(-0.9,0)
	self._canCastSpell3 = false
end

function KeyBoardControl:onMoveDown()
	if self._ctrlType == stickType then
		return
	end
	self._ctrlType = keyBoardType
	self._key.y = -1.0
	self:addState(key.down)
	self:StickPos()

	self._dir = cc.p(0,-1)
	self._canCastSpell3 = false
end

function KeyBoardControl:onMoveRight()
	if self._ctrlType == stickType then
		return
	end
	self._ctrlType = keyBoardType
	self._key.x = 1.0
	self:addState(key.right)
	self:StickPos()

	self._dir = cc.p(0.9,0)
	self._canCastSpell3 = false
end

function KeyBoardControl:onReleaseUp()
	if self._ctrlType == stickType then
		return
	end 
	self:removeState(key.up)
	if self:hasState(key.down) then
		self._key.y = -1.0
	else
		self._key.y = 0
	end
	self:StickPos()

	self._dir = cc.p(0,0)
end

function KeyBoardControl:onReleaseLeft()
	if self._ctrlType == stickType then
		return
	end
	self:removeState(key.left)
	if self:hasState(key.right) then
		self._key.x = 1.0
	else
		self._key.x = 0
	end
	self:StickPos()

	self._dir = cc.p(0,0)
end

function KeyBoardControl:onReleaseDown()
	if self._ctrlType == stickType then
		return
	end
	self:removeState(key.down)
	if self:hasState(key.up) then
		self._key.y = 1.0
	else
		self._key.y = 0
	end
	self:StickPos()

	self._dir = cc.p(0,0)
end

function KeyBoardControl:onReleaseRight()
	if self._ctrlType == stickType then
		return
	end
	self:removeState(key.right)
	if self:hasState(key.left) then
		self._key.x = -1.0
	else
		self._key.x = 0
	end
	self:StickPos()

	self._dir = cc.p(0,0)
end

function KeyBoardControl:StickPos()
	local node = self._stick.node
	local radius = self._stick.radius
	local orgPos = self._stick.orgPos
	local d = self._key
	local pos = node:pos(orgPos.x+d.x*radius,orgPos.y+d.y*radius)
	node:pos(pos)
	self:MoveToDir(self._key)
end

function KeyBoardControl:MoveToDir(dir)
	--cclog("set Dir x:%.2f y:%.2f",dir.x,dir.y)
	local player = self._controller
	if self._keyState == 0 then
		self._ctrlType = nil
		self._controller:stand()
		-- 设置摄像机状态
		player._map:getCameraMgr():endmove()
		--cclog("Camera endmove")
	else
		self._controller:setDir(dir)
		self._controller:move()
		-- 设置摄像机状态
		local player = self._controller
		player._map:getCameraMgr():startmove(dir.x)
		--cclog("Camera starMove "..dir.x)
	end
end

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

function KeyBoardControl:ClickOn(pt)
	--if cc.rectContainsPoint(self.touchRect,pt) == false then return end
	
	--if circleContainsPoint(self._touchCircleRadius,pt,self._touchCircleCenter) == false then 
		local item = nil
		local mapPos = cc.pAdd( pt, cc.pMul(self._controller._map._mapLayer:pos(),-1) )
		for obj,_ in pairs(self._objects) do
			if obj:getType() == ItemType then
				local box = obj:getBox()
				if cc.rectContainsPoint(box,mapPos) then
					self._controller:pickUpItem(obj)
					item = obj
					cclog("get item!!!!!!!!!!!!!!!!!!")
					break
				end
			end
		end
		if item ~= nil then
			GameLogic:removeItem(item:getGuid())
		end
	--end
	--self:moveStick(pt)
end

function KeyBoardControl:drag(pt)
	--[[
	local rect = self.touchRect
	if pt.x > cc.rectGetMaxX(rect) then
		pt.x = cc.rectGetMaxX(rect)
	end
	if pt.x < cc.rectGetMinX(rect) then
		pt.x = cc.rectGetMinX(rect)
	end
	if pt.y > cc.rectGetMaxY(rect) then
		pt.y = cc.rectGetMaxY(rect)
	end
	if pt.y < cc.rectGetMinY(rect) then
		pt.y = cc.rectGetMinY(rect)
	end
	self:moveStick(pt)]]
	if pt.x < 0 then pt.x = 0 end
	if pt.y < 0 then pt.y = 0 end
	local pos = pt
	if circleContainsPoint(self._touchCircleRadius,pt,self._touchCircleCenter) == false then
		local radian = radians4point(self._touchCircleCenter.x,self._touchCircleCenter.y,pt.x,pt.y)
		pos.x,pos.y = pointAtCircle(self._touchCircleCenter.x,self._touchCircleCenter.y,radian,self._touchCircleRadius)
	end
	self:moveStick(pos)
end

function KeyBoardControl:ClickEnd(pt)
	self:releaseStick()
end

function KeyBoardControl:moveStick(m_pos)
	if self._ctrlType == keyBoardType then
		return 
	end
	self._ctrlType = stickType
	--local m_pos = uiwidget:getTouchMovePosition()
	local orgPos = self._stick.orgPos
	local radius = self._stick.radius
	local node = self._stick.node
	local pos = m_pos
	--if cc.pGetDistance(pos,orgPos) > radius then
	--	pos = cc.pAdd(orgPos,cc.pMul(cc.pNormalize(cc.pSub(m_pos,orgPos)),radius))
	--	node:pos(pos)
	--else
		node:pos(pos)
	--end

	local dir = cc.pNormalize(cc.pSub(pos,orgPos))
	--cclog("dir x:"..dir.x.. " y:"..dir.y)
	self._controller:setDir(dir)
	self._controller:move()

	self._dir = dir
	self._canCastSpell3 = false

	-- 设置摄像机状态
	local player = self._controller
	if self._dir.x > 0 then
		player._map:getCameraMgr():startmove(1)
	else
		player._map:getCameraMgr():startmove(-1)
	end
end

function KeyBoardControl:releaseStick()
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

	-- 设置摄像机状态
	local player = self._controller
	player._map:getCameraMgr():endmove()
end

function KeyBoardControl:onClick(uiwidget)
	self._clickMeleeBtnTime = 0
	if self._dir.x == 0 and self._dir.y == 0 then
		self._canCastSpell3 = true
	end


end

function KeyBoardControl:canCastSpell()
	local spellIndex = 0
	if self._dir.x == 0 and self._dir.y == 0 then
		if self._canCastSpell3 and self._clickMeleeBtnTime 
			> sMiscValueInfo[miscValue.clickMeeleBtnTime].value then
			spellIndex = 3
		end
	elseif self._dir.y >= 0.9 then --上方向
		spellIndex = 1 
	elseif self._dir.y <= -0.9 then --下方向
		spellIndex = 2
	end

	return spellIndex
end

function KeyBoardControl:onClickAttk(uiwidget)
	if self._controller:canAttack() == false then return end

	local spellIndex = self:canCastSpell()
	if spellIndex == 1 or spellIndex == 2 then
		--cclog("英雄将释放技能"..spellIndex)
		return
	end

	if self._clickMeleeBtnTime <= sMiscValueInfo[miscValue.clickMeeleBtnTime].value then
		if self._controller:attack() then
			if math.abs(self._dir.x) >= 0.9 then
				--cclog("player向攻击方向滑行一小段距离")
				self._controller:slideWhenAttack()
			end
		end
	end
	self._clickMeleeBtnTime = 0
	self._canCastSpell3 = false


end

function KeyBoardControl:update(dt)
	self:updateClickBtnTime(dt)
	self:updateControllerMove(dt)
end

function KeyBoardControl:updateClickBtnTime(dt)
	self._clickMeleeBtnTime = self._clickMeleeBtnTime + dt

	if self:canCastSpell() == 3 then
		--cclog("英雄将释放技能3")
		self._canCastSpell3 = false
	end
end

function KeyBoardControl:updateControllerMove( dt )
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


--	adjustPos(pos,movePos)
end

function KeyBoardControl:onCastSpell1()
	self._controller:castSpell(4)
end

function KeyBoardControl:onCastSpell2()
	self._controller:castSpell(5)
end

function KeyBoardControl:onCastSpell3()
	self._controller:castSpell(7)
end

return KeyBoardControl