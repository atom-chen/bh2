local GObject = require("Logic.GObject")
local GameActor = require("Object.GameActor")
local phymod_fly = require("Common.phymod_fly")
local SpellDisplay = require 'Spell.SpellDisplay'
local AuraMgr = require 'Spell.AuraMgr'

--require("Logic.ysn_spell")
local ThreatList = require("AI.ThreatList")
local MotionMgr = require "AI.MotionMgr"
local SpellMgr = require 'Spell.Mgr'

state = state or 
{
	stand 	= BIT(0),
	move 	= BIT(1),
	skill 	= BIT(2),
	floating = BIT(3),
	hurt	= BIT(4),
	down 	= BIT(5),
	up 		= BIT(6),
	monsterMove = BIT(7),
	just_dead 	= BIT(8),			-- 才开始死
	dead 		= BIT(9),			-- 死透了
	respawn		= BIT(10),			-- 等待复活
}

state.cannotControl = state.floating+state.down+state.hurt

local anim =
{
	stand = "stand",
	run = "walk",
	hurt = "hurt",
	down = "laydown",
	downhurt = "laydownhurt",
	stun = "stun",
	up = "up",
	floating = "float",
	attack1 = "attack1",
	attack2 = "attack2",
	attack3 = "attack3",
	skill1 = "skill1",
	skill2 = "skill2",
	skill3 = "skill3",
	skill4 = "skill4",
	dead = "dead",
	float3 = "float3",
	float4 = "float4",
	float5 = "float5",
	fallingup = "float8_tanqi",
}

local Unit = class("Unit",GObject)
Unit.__index = Unit

function Unit:ctor(info,type)
	self:init()
	self._info = info
	self:createActor()
	self._state = state.stand
	self._to = state.stand
	self._schedule = nil
	self:speed(display.p(sMiscValueInfo[miscValue.playerMoveX].value,sMiscValueInfo[miscValue.playerMoveY].value))
	self:stand()
	self._locked = false
	self._action = false
	self._ai = nil

	self._face = 0  -- 面向,faceleft|faceright

	self._down = 
	{
		time = 0,
	}

	self._back = 
	{
		time = 0,
		speed = cc.p(0,0)
	}

	self._goto = 
	{
		time = cc.p(0,0),
		elapsed = 0,
		ePos = cc.p(0,0),
		oPos = cc.p(0,0),
		delta = cc.p(0,0),
		speed = cc.p(0,0),
	}

	self._type = type

	self._log = {}

	self._castSpell = nil
	self._spells = {}
	self._AuraMgr = AuraMgr.new() 

	self._deadFunc = nil
	self._addToWorld = false

	-- 震动接口
	self._timerShake = 0 			-- 震动计时器
	self._shakeDurtion = 0.05		-- 持续时间
	self._shakeCount = 0 			-- 震动次数
	self._shakeDisX = 0 			-- 震动位移X
	self._shakeDisY = 0 			-- 震动位移Y
	self._shakeDir = 1 				-- 震动方向

	-- 仇恨列表
	self._threatList = ThreatList.new()
	-- 视野列表
	self._viewList = {}
	-- 移动管理器
	self._MotionMgr = MotionMgr.new()

	-- 物理计算
	self._phymod_fly = phymod_fly.new()

	-- 技能
	self._SpellMgr =  SpellMgr.new(self)

	self:ResetComboTime()
	self._comboCount = 0

	-- 摄像头管理
	self._cameraTimer = 0
	self._cameraEvent = 0
	self._cameraPos = {x=0,y=0}
	self._s = 0
	self._t = 0
end

function Unit:createActor()
	self._actor = GameActor.new(self._info.json,self._info.atlas)
--	self._actor:loadEffect(self._info.effectJson,self._info.effectAtlas)
	CC_SAFE_RETAIN(self._actor)
end

function Unit:addToWorld(map,pos,face,ai)
	self:setMap(map)
	self:setPos(pos)
	self:setAI(ai)
	self:setDir(cc.p(face,0))
	self._face=face
	self._map:addSceneObject(self)
	--self._schedule = sharedDirector:getScheduler():scheduleScriptFunc(handler(self,self._update),0,false)
	self._addToWorld = true
end

function Unit:isInWorld()
	return self._addToWorld
end

function Unit:removeFromWorld()
	--debug--
	if self._bound then
		self._map:removeChild(self._bound)
	end
	--debug--
	self._map:removeSceneObject(self)
	CC_SAFE_RELEASE(self._actor)
	self._addToWorld = false
	--self:Exit()
end

function Unit:ActorPlay(action,loop,scale)
	--cclog("ActorPlay aciotn :"..action)
	self._actor:play(action,loop,scale)
	self._actor:setCallBack(action,function(event) 
			local data = event.eventData
			if data.name == "key" then
				self:ready()
			end
		end,sp.EventType.ANIMATION_EVENT)
	self._actor:setCallBack(action,function(event)
			self:finishAttk()
			self._actor:setCallBack(event.animation,nil,sp.EventType.ANIMATION_END)
			cclog(action.." unlocked")
			self._locked = false
			self._action = false
		end,sp.EventType.ANIMATION_END)
end

function Unit:Exit( )	
	local scheduler = sharedDirector:getScheduler()
	scheduler:unscheduleScriptEntry(self._schedule)
end

function Unit:getMotionMgr()
	return self._MotionMgr
end
function Unit:getThreatMgr()
	return self._threatList
end

function Unit:getType()
	return self._type
end

function Unit:getZ()
	return self._actor:getLocalZOrder()
end

function Unit:setMap( map )
	self._map = map
	self._boundDirty = true

	self._map:GetMapUI():updateHp(self:getHp(),self:getMaxHp())
end

function Unit:setAI(ai)
	self._ai = ai
	if ai then
		ai:setCtrl(self)
	end
end

function Unit:stand()
	self:stopMove()
	self:stopMonsteMove()
	self:addState(state.stand)
	self:to(state.stand)
end

function Unit:move()
	if self:hasState(state.move) == false then
		self:addState(state.move)
		self:to(state.move)
	end
end

function Unit:ActionLocked()
	return self._locked
end

function Unit:action()

	if self._action == false and self._locked == false then
		if self._to == state.stand and self:isNotControl() == false then
			--cclog("%s stand",self:getName())
			--assert(iskindof(self._actor,"GameActor"))
			self._actor:play(anim.stand,true)
			self._action = true
		elseif self._to == state.move and self:canMove() then
			--cclog("%s walk",self:getName())
			self._actor:play(anim.run,true,1.4)
			self._action = true
		elseif self._to == state.monsterMove and self:canMonsterMove() then
			--cclog("%s monster move",self:getName())
			self._actor:play(anim.run,true,1.4)
			self._action = true
		elseif self._to == state.just_dead then
			self._actor:play(anim.dead,false)
			self._action = true
		end
	end
end

function Unit:playHurt()
	if self:hasState(state.down) then
		if self._down.time > 0 then
			self._actor:play(anim.downhurt,false)
		end
	elseif self:hasState(state.up) == false then
		self._actor:play(anim.hurt,false)
	end
end

function Unit:setPos(pos)
	self._actor:pos(self:pos(pos))
end

function Unit:setScreenPos(pos)
	self._actor:pos(self:pos(pos))
end

function Unit:getScreenPos()
	local pos ={}
	pos.x = self._actor:pos().x - self._map:getFloorPos().x
	pos.y = self._actor:pos().y - self._map:getFloorPos().y
	return pos
end

function Unit:onChangeDirFunc(dir)
	--cclog("set dir")
	self._actor:setDir(dir)
	-- 当为0的时候暂时不改变面向
	if dir.x > 0 then
		self._face = faceright
	elseif dir.x < 0 then
		self._face = faceleft
	end
end

function Unit:stopMove()
	self:removeState(state.move)
end

function Unit:canMove()
	if self:isNotControl() then
		return false
	else
		return self._state <= state.move+state.stand
	end
end

function Unit:canMonsterMove()
	if self:hasState(state.floating) or self:hasState(state.down) or self:hasState(state.hurt) or
	 self:hasState(state.up) or self:hasState(state.just_dead) or self:hasState(state.dead) then
		return false
	else
		return true
	end
end

function Unit:canAttack()
	if self:isNotControl() then
		return false 
	else
		return GObject.canAttack(self)
	end
end

function Unit:canTurn()
	if self:hasState(state.monsterMove) then
		return self:canMonsterMove()
	elseif self:hasState(state.down) then
		return false
	else
		return self:canAttack()
	end
end

function Unit:getFace()
	return self._face
end

function Unit:goto(pos,speed,handle)
	speed = speed or self:speed()
	self._goto.oPos = self:pos()
	local delta = cc.pSub(pos,self._goto.oPos)
	self._goto.ePos = pos
	self._goto.delta = delta
	self._goto.speed = speed
	self._goto.time.x = math.abs(self._goto.delta.x/speed.x)
	self._goto.time.y = math.abs(self._goto.delta.y/speed.y)
	self._goto.elapsed = 0
	local dir = cc.pNormalize(cc.pSub(pos,self._goto.oPos))
	self:setDir(dir)
	self._goto.handle = handle
	self:stopMove()
	self:addState(state.monsterMove)
	self:to(state.monsterMove)
end

function Unit:resetMonsterMove()
	local speed = self._goto.speed
	self._goto.oPos = self:pos()
	local delta = cc.pSub(self._goto.ePos,self._goto.oPos)
	self._goto.delta = delta
	self._goto.time.x = math.abs(self._goto.delta.x/speed.x)
	self._goto.time.y = math.abs(self._goto.delta.y/speed.y)
	self._goto.elapsed = 0
	local dir = cc.pNormalize(cc.pSub(self._goto.ePos,self._goto.oPos))
	self:setDir(dir)
end

function Unit:stopMonsteMove()
	self:removeState(state.monsterMove)
end

function Unit:isNotControl()
	if self:hasState(state.floating) or self:hasState(state.down) or self:hasState(state.hurt) or
	 self:hasState(state.up) or self:hasState(state.monsterMove) or self:hasState(state.just_dead) or self:hasState(state.dead) then
		return true
	else
		return false
	end
end

function Unit:slideWhenAttack() --攻击时滑行一段距离
	local pos = self:pos()
	if self:dir().x > 0 then
		pos.x = pos.x + sMiscValueInfo[miscValue.slideDis].value
	else
		pos.x = pos.x - sMiscValueInfo[miscValue.slideDis].value
	end
	self:setPos(pos)
end

function Unit:onAttackFunc(attk)
	self._locked = true
	self:castSpell(self._fields.attack[attk])
end

function Unit:onDead()
	if self:hasState(state.just_dead) then return end
	if self:hasState(state.down) == false then
		self:stopKnockBack()
		self._down.time = 0
		self:removeState(state.up)
		cclog("onDead unlocked")
		self._locked = false
		self._action = false
		self:FadeOut()
		self:addState(state.just_dead)
		self:to(state.just_dead)
	end
end

function Unit:FadeOut()
	local deadTime = self:getDeadTime()
	self._actor:FadeOut(deadTime,handler(self,self.RunDeadFunc))
end

function Unit:RegisterDeadFunc(func)
	self._deadFunc = func
end

function Unit:RunDeadFunc()
	if self._deadFunc then
		self._deadFunc()
	end
	self:addState(state.dead)
end

function Unit:isDead()
	if self:hasState(state.dead) then
		return true
	end
	return false
end

function Unit:transWorldToScreen(worldPos)
	return worldPos
end

function Unit:transMapToScreen(mapPos)
	local screenPos = cc.pAdd( mapPos,self._map._mapLayer:pos())
	return screenPos
end

function Unit:transScreenToMap(screenPos)
	local mapPos = cc.pAdd( screenPos, -self._map._mapLayer:pos() )
	return mapPos
end


function Unit:transScreenToWorld(screenPos)
	return screenPos
end

function Unit:getScreenPos()
	return self:transMapToScreen( self:pos() )
end

function Unit:update(dt)
	self:updateAura(dt)
	self:updateSpell(dt)

	if self._ai then
		self._ai:update(dt)
		self._MotionMgr:update()
	end

	if self:hasState(state.move) and self:canMove() then
		self:updateMove(dt)
	end

	if self:hasState(state.monsterMove) and self:canMonsterMove() then
		self:updateMonsterMove(dt)
	end

	self:action()
	self:DrawBound()
	self:updateBack(dt)
	self:updateDown(dt)
	self:updateLog()
	self:updateShake(dt)
--	self:DrawEffectBound()
	self:updateComboTime(dt)

	--self._map:CameraAccMoveToMapX(-1000,200,60,dt)
	--self._map:CameraMoveA(1000,100,10,dt)
--[[	
	if self._cameraEvent == 0  then
		self._cameraPos.x = self:pos().x
		self._cameraPos.y = self:pos().y

	--	local sPos = self:TransMapToScreen(self._cameraPos)
	--	if sPos.x >= winSize.width/2 then
	--		self._cameraEvent = 1
	--	elseif sPos.x < winSize.width/2 and sPos.x >= winSize.width/3 then
			self._cameraEvent = 1
	--	end
	end

	local speed = self:speed()
	if self._cameraEvent == 1 or self._cameraEvent == 2 then	-- 等一会然后移动
		self._cameraTimer =  self._cameraTimer + dt
		
		if self._cameraTimer > 0.3 then
			if self._cameraEvent == 1 then
				local pos = self:pos()
				if( pos.x>= self._cameraPos.x ) then 
					self._cameraDir = -1
				else
					self._cameraDir = 1 
				end
				self._s = math.abs(self._cameraPos.x - pos.x)
				self._cameraEvent = 2
				cclog("SSSSSS:%d",self._s)
			end 

			if self._cameraEvent == 2 then
				--self._map:CameraMoveTo(speed.x,dt)
				--self._map:CameraMoveTo(1000,speed.x,0,dt)
				--self._t = self._t + dt
				local r = self._map:CameraMoveA(self._s,speed.x/3,250,dt,self._cameraDir)
				if r.y == 1 then 
					self._s = 0
					self._t = 0
					self._cameraTimer = 0
					self._cameraEvent = 0
					self._map._cameramove = 0
					cclog("EEEEEE:%d",r.x)
				end 
			end
		else
			
		end
	end
]]
end

function Unit:updateComboTime(dt)
	if self._combatEffectiveTime > dt then
		self._combatEffectiveTime = self._combatEffectiveTime - dt
	else
		self._combatEffectiveTime = 0
	end
end

function Unit:isHostileTo(obj)
	local ret = false
	if self._type ~= obj._type then
		ret = true 
	end
	return ret
end

function Unit:updateVisableFor(pl)
	self._viewList[pl] = 0

	-- 如果是敌对的
	if self:isHostileTo(pl) then
		self:getThreatMgr():add(pl)
	end
	-- 触发AI脚本
	if self._ai then
		self._ai:MoveInLineOfSight(pl)
	end
end

function Unit:moveToCenter(duration)
	duration = duration or 2

	local offset = 0
	if self:pos().x + self._map:getOffset() > winSize.width/2 then
		offset = 0 - (self:pos().x + self._map:getOffset() - winSize.width/2)
	else
		offset = 0--winSize.width/2 - (self:pos().x + self._map:getOffset())
	end
	cclog("move offset:"..offset/2)
	local posx = self:pos().x + offset/2
	cclog("player will moveto x:"..posx)
	local moveto = cc.MoveTo:create(duration,cc.p(posx,self:pos().y))
	local func = cc.CallFunc:create(function ()
		self:pos(self._actor:pos())
	end)
	self._actor:runAction(cc.Sequence:create(moveto,func))
end

function Unit:checkPos( pos )
	if pos.x < 0 then
		pos.x = 0
	elseif pos.x > self._map._lockRect.width then
		pos.x = self._map._lockRect.width
	end
	if pos.y < 0 then
		pos.y = 0
	elseif pos.y > self._map._lockRect.height then
		pos.y = self._map._lockRect.height
	end
end

function Unit:updateMove( dt )

--[[	
	local pos = self:pos()
	local dir = self:dir()
	local speed = self:speed()
	pos.x = pos.x + speed.x * dt * dir.x
	pos.y = pos.y + speed.y * dt * dir.y
	self:checkPos(pos)

	self:setPos(pos)
	--cclog("player posx:%.2f y:%.2f",pos.x,pos.y)

	self._boundDirty = true
	]]

	local pos = self:pos()
	local dir = self:dir()
	local speed = self:speed()
	pos.x = pos.x + speed.x * dt * dir.x
	pos.y = pos.y + speed.y * dt * dir.y
	self:checkPos(pos)

	if self:getScreenPos().x <= winSize.width/2 then
		self:setPos(pos)
	else
		self:setPos(pos)	
	end


	--cclog("player posx:%.2f y:%.2f",pos.x,pos.y)


	self._boundDirty = true
end

function Unit:updateMonsterMove(dt)
	local dir = self:dir()
	self._goto.elapsed = self._goto.elapsed + dt
	local percentX = math.min(1,self._goto.elapsed/self._goto.time.x)
	local pos = clone(self._goto.delta)
	pos.x = pos.x * percentX
	local percentY = math.min(1,self._goto.elapsed/self._goto.time.y)
	pos.y = pos.y * percentY
	pos = cc.pAdd(self._goto.oPos,pos)
	self:setPos(pos)
	--cclog("precentX:%.2f,precentY:%.2f pos.x:%.2f, pos.y:%.2f",percentX,percentY,pos.x,pos.y)
	if percentY == 1 and percentX == 1 then
		self:removeState(state.monsterMove)
		if self._goto.handle then
			self._goto.handle()
		end
		self:stand()
	end
	self._boundDirty = true
end

function Unit:onKnockBack()
	self:finishAttk()
	self._SpellMgr:cancelSpell()
	self:addState(state.hurt)
	--self:to(state.hurt)
	cclog("onKnockBack locked")
	self._locked = true
	self:playHurt()
	self._back.time = self:getBackTime()
	self._back.speed = self:speed()
	--self:speed(cc.p(0,0))
	
	self._map:ShakeUnderAttack()
	self:ShakeUnderAttack()
end

function Unit:stopKnockBack()
	self:removeState(state.hurt)
	self._back.time = 0
	cclog("stopKnockBack unlocked")
	self._locked = false
	self._action = false
	self:speed(self._back.speed)
end

function Unit:updateBack(dt)
	if self._back.time > 0  then
		self._back.time = self._back.time - dt
		if self._back.time <= 0 then
			self:stopKnockBack()
		end
	end
end

function Unit:onKnockDown()
	self:finishAttk()
	self._SpellMgr:cancelSpell()
	self:addState(state.down)
	cclog("onKnockDown locked")
	self._locked = true
	self._actor:play(anim.float3,false,1)
	local face = self:getFace()
	self._phymod_fly:setStartPos(self:pos())
	self._phymod_fly:force(-1*face*420,680,140,1111)
	self._down.time = 0
end

function Unit:onFallingUp()
	cclog("%s falling up", self:getName())
	self._actor:play(anim.fallingup,false)
	self._down.time = self._fields.downTime
	self._locked = true
	cclog("onFallingUp locked")
end

function Unit:onUp()
		cclog("%s up",self:getName())
		self:removeState(state.down)
		self:addState(state.up)
		self._actor:play(anim.up,false)
		self._actor:setCallBack(anim.up,function(event)
		self:removeState(state.up)
		self._actor:setCallBack(event.animation,nil,sp.EventType.ANIMATION_END)
		cclog("onUp unlocked")
		self._locked = false
		self._action = false
	end,sp.EventType.ANIMATION_END)
		self._locked = true
		cclog("onUp locked")
		self:resetMonsterMove()
end

function Unit:checkDownPos( pos )
	if pos.x < 0 then
		pos.x = 0
	elseif pos.x > self._map._lockRect.width then
		pos.x = self._map._lockRect.width
	end
	if pos.y < 0 then
		pos.y = 0
	elseif pos.y > winSize.height then
		pos.y = winSize.height
	end
end

function Unit:updateDown(dt)
	if self._phymod_fly:running()  then
		self._phymod_fly:update(dt)
		local offsetPos = self._phymod_fly:getOutPos()

		local pos = self:pos() 
		self:checkDownPos(offsetPos)
		local height = offsetPos.y - pos.y
		self:setHeight(height)
		self:pos(offsetPos.x,pos.y)
		self._actor:pos( offsetPos )
		self._boundDirty = true

		if self._phymod_fly:getPhase() == ModPhase.up then 
			self._actor:play(anim.float3,false,1)
		elseif self._phymod_fly:getPhase() == ModPhase.down then 
			self._actor:play(anim.float4,false,1)
		elseif self._phymod_fly:getPhase() == ModPhase.floor then 
			--self._actor:play(anim.float5,false,1)
			self._phymod_fly:reset()
			self._phymod_fly:stop()
			self:onFallingUp()
		end
	end 

	if self._down.time > 0 then
		self._down.time = self._down.time - dt
		if self._down.time <= 0 then
			self._down.time = 0
			self:onUp()
		end
	end

end

function Unit:addState(state)
	self._state = bor(self._state,state)
	--cclog("player state :%x",self._state)
end

function Unit:hasState(state)
	return band(self._state,state) > 0
end

function Unit:removeState(state)
	self._state = band(self._state,bnot(state))
	--cclog("player state :%x",self._state)
end

function Unit:to(state)
	self._to = state
	self._action = false
end

function Unit:addBattleLog(log)
	self._log[#self._log+1] = log
end

function Unit:UpdateHp()
	if self._type == MonsterType then
		local per = self:getHp() / self:getMaxHp() * 100
		self:UpdateHpBar(per)
	else
		self._map:GetMapUI():updateHp(self:getHp(),self:getMaxHp())
	end
end

function Unit:ResetComboTime()
	self._combatEffectiveTime = sMiscValueInfo[miscValue.comboTime].value--3
end

function Unit:combo()
	if self._comboCount > 0 then
		if self._combatEffectiveTime <= 0 then
			self._comboCount = 0
		end
	end
	self._comboCount = self._comboCount + 1
	self:ResetComboTime()

	if self._type == PlayerType then
		self._map:GetMapUI():AddCombo(self._comboCount)
	end
end

function Unit:updateLog()
	for k,v in ipairs(self._log) do
		cclog("受到[%d] %d",v.damageType,v.damage)
		self:addCombatInfo(v)

		self:UpdateHp()
	end
	self._log = {}
end

function Unit:addCombatInfo(log)
	--local randVal = math.random(20,100)
	local combatinfo = require("utils.CombatInfo").new(self._actor,randVal or log.damage,log.damageType)
	--self._actor:addChild(combatinfo)
	--combatinfo:pos(0,self._actor:pos().y + self:getBox().height * 0.35)
	self._map._uiLayer:addChild(combatinfo)
	combatinfo:pos(self:getScreenPos().x,self:getScreenPos().y + self:getBox().height * 1.35)
end

-- debug

local RED = cc.c4f(1.0,0,0,1.0)

function Unit:DrawBound()
	if self._boundDirty then
		if not self._bound then
			self._bound = cc.DrawNode:create()
			self._map:addChild(self._bound,999)
		end
		local rect = self:getBox() 
		local pos = self:getScreenPos()
		rect.x = pos.x - rect.width/2
		rect.y = pos.y + self:getHeight()
		self._bound:clear()
		self._bound:drawRect(cc.p(rect.x,rect.y),cc.p(rect.x+rect.width,rect.height+rect.y),RED)
		self._boundDirty = false
		--self:DrawViewRange()
	end
end

--

-- Spell
function Unit:castSpell(id)
	if self._castSpell then
		self._SpellMgr:cancelSpell(self._castSpell)
	end
	self:addState(state.skill)
	self._castSpell = self._SpellMgr:addSpell(id)
end

function Unit:TriggerSpell(id)
	self._SpellMgr:addSpell(id)
end

function Unit:finishSpell(guid)
	--cclog("finshSpell :"..spell._info.id)
	if guid == self._castSpell then
		self._locked = false
		self._action = false
		self._castSpell = 0
		self:removeState(state.skill)
	end
end

function Unit:SpellResult(id,err)
end

function Unit:updateSpell(dt)
	self._SpellMgr:update(dt)
end

function Unit:addAura(effect)
	self._AuraMgr:addAura(self,effect)
end

function Unit:updateAura(dt)
	self._AuraMgr:update(dt)
end

-------------------------------------------------------------------

function Unit:ShakeUnderAttack()
	self:ScreenShake(1,1,4,0,0.01)
end
-- 角色屏幕震动对外接口
function Unit:ScreenShake(n,direction,distanceX,distanceY,durtion)
	self._shakeCount = 12
	self._shakeDir = direction
	self._shakeDurtion = durtion
	self._shakeDisX = distanceX
	self._shakeDisY = distanceY
end

function Unit:updateShake(dt)
	if self._shakeCount > 0 then 
		self._timerShake = self._timerShake + dt

		local step = self._shakeCount
		local dur = self._shakeDurtion
		local x = 0
		if( step == 12 ) then 
			dur = self._shakeDurtion
			x = self._shakeDisX 
		elseif( step == 11 ) then 
			dur = self._shakeDurtion
			x = -self._shakeDisX  
		elseif( step == 10 ) then 
			dur = self._shakeDurtion
			x = -self._shakeDisX *2
		elseif( step == 9 ) then
			dur = self._shakeDurtion 
			x = self._shakeDisX *2
		elseif( step == 8 ) then
			dur = self._shakeDurtion
			x = self._shakeDisX *2
		elseif( step == 7 ) then
			dur = self._shakeDurtion
			x = -self._shakeDisX *2 
		elseif( step == 6 ) then
			dur = self._shakeDurtion
			x = -self._shakeDisX *2 
		elseif( step == 5 ) then
			dur = self._shakeDurtion
			x = self._shakeDisX *2 
		elseif( step == 4 ) then
			dur = self._shakeDurtion
			x = self._shakeDisX
		elseif( step == 3 ) then
			dur = self._shakeDurtion
			x = -self._shakeDisX
		elseif( step == 2 ) then
			dur = self._shakeDurtion
			x = -self._shakeDisX
		elseif( step == 1 ) then
			dur = self._shakeDurtion
			x = self._shakeDisX
		end

		if ( self._timerShake > dur ) then
			--cclog("shakeUnit:%d,%d",self._shakeCount,x)
			self:shake(x,0)
			self._timerShake = 0
			self._shakeCount = self._shakeCount - 1
		end
	end
end 

function Unit:shake(a,b)
	local x = self._actor:pos().x
	local y = self._actor:pos().y
	self._actor:pos(cc.p(x+a,y+b))
end

--[[
战斗数值处理

]]

function Unit:getHostile(condition,targets)
	local res = targets or {}
	local threat = self:getThreatMgr():getAll()
	for unit,_ in pairs(threat) do
		if not condition or condition(unit) and not targets[unit] then
			res[unit] = false
		end
	end
	return res
end

function Unit:dealDamage(target,count)
	local hp = target:getHp() 

	if( hp - count <= 0) then
		--死亡处理
	else
		hp = hp - count 
	end

	target:setHp(hp)
end


--[[
]]

function Unit:onHit(log)
	local Auras = self._AuraMgr:getAuras(AuraMod.absorbdamage)
	local valueMod = log.valueMod
	local damage = log.damage
	local damage_pct = log.value_pct
	local hitback = log.hitback
	local hitdown = log.hitdown
	local absorb = 0
	log.absorb = 0

	if valueMod == 0 then
		for k,aura in pairs(Auras) do
			absorb,damage = aura:Absorb(damage)
			log.absorb = absorb + log.absorb
		end
		if damage > 0 then
			self:modifyHp(-damage*(1+damage_pct))
		end
	elseif valueMod == 1 then
		self:modifyMp(-damage)
	end
	log.damage = damage
	log.absorb = absorb
	if damage > 0 then
		self:modifyKBValue(hitback)
		self:modifyKDValue(hitdown)

		local displayId = sSpellEntry[log.spellId].displayID
		local entry = sSpellDisplayStore[displayId]
		local info = sSpineStore[entry.hurt]
		if info then
			cclog("hurt :"..info.animation)
			local hurt_display = GameActor.new(info.json,info.atlas)
			hurt_display:play(info.animation,false,1,sp.EventType.ANIMATION_COMPLETE,function(event)
				hurt_display:runAction(cc.RemoveSelf:create())
				end)
			self._actor:addChild(hurt_display)
		end
		self._AuraMgr:triggerOnHit()
	elseif log.absorb > 0 then
		-- 可以播放吸收特效
		cclog("吸收走起")
	end
	self:addBattleLog(log)
end

return Unit

