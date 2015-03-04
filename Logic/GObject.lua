object = object or {}

object.cmd = 
{
	attk = 0,
	skill1 = 1,
	skill2 = 2,
	skill3 = 3,
	skill4 = 4,
	dir 	= 5,
} 

local GObject = class("GObject")
GObject.__index = GObject

local field = 
{
	name = "玩家",
	hp = 1000000,
	maxHp = 1000000,
	mp = 10,
	maxMp = 10000,
	pos = uber.p(0,0),			-- 脚底坐标
	height = 0,					-- 脚底离地高度
	size = uber.size(50,100),	-- 通过模型设置,这里只是一个预设
	speed = cc.p(0,0),			-- 移动默认速度
	direction = cc.p(0,0),		-- 人物方向,向量
	viewRange = cc.size(200,200),

	kdValue = 0, -- knockdown value
	kbValue = 0, -- knockback value
	resistKd = 100,	-- resist knockdown
	resistKb = 100,	-- resist knockback
	recoverKd = 20,	-- 每0.2s回复 knockdown 的值
	recoverKb = 20, -- 每0.2s回复 knockback 的值

	backDis = 0/display._scale,		-- 击退距离
	backSpeed = 0/display._scale,	-- 后退的速度

	downSpeed = uber.p(80,80),		-- 击倒向后方飞出到最高点之前的速度
	fallSpeed = uber.p(80,80),		-- 从最高点下落时的速度
	downTime = 1,					-- 躺在地上的时间
	godTime = 2,					-- 起身无敌时间
	deadTime = 2,					-- 消失时间

	attack = {1,2,3},			-- 3连击技能Id
	skill = {4,5,6,7},			-- 4个技能的Id
}

local sk = 
{
	prepare = 0,
	start = 1,
	finish = 2,
}

local attk = 
{
	ready = 0,
	anybody = 1,
}

local maxCombo = 3

function GObject:ctor()
	self:init()
end

function GObject:init()
	self._fields = clone(field)
	self._attkstate = attk.ready
	self._skillstate = sk.finish
	self._attk = 
	{
		combo = 1,
		cur = 1,
	}
	self._cmdDir =
	{
		dst = nil,
	}

	self._kd = 
	{
		time = 0,
	}

	self._kb = 
	{
		time = 0,
	}
	self._commands = {}
end

function GObject:getMaxHp()
	return self._fields.maxHp
end

function GObject:getHp()
	return self._fields.hp
end

function GObject:setHp(hp)
	self._fields.hp = math.min(hp,self._fields.maxHp)
	self._fields.hp = math.max(0,self._fields.hp)
end

function GObject:setMp(mp)
	self._fields.mp = math.min(hp,self._fields.maxMp)
	self._fields.mp = math.max(0,self._fields.mp)
end

function GObject:isAlive()
	return self._fields.hp > 0
end

function GObject:dead()
	return self:isAlive() == false
end

function GObject:getMp()
	return self._fields.mp
end

function GObject:getName()
	return self._fields.name
end

function GObject:viewRange()
	return clone(self._fields.viewRange)
end

function GObject:setHeight(h)
	self._fields.height = h
end

function GObject:getHeight()
	return self._fields.height
end

function GObject:getDeadTime()
	return self._fields.deadTime
end

function GObject:modifyHp(value)
	self:setHp(self._fields.hp+value)
end

function GObject:modifyMp(value)
	self:setMp(self._fields.mp+value)
end

function GObject:modifyKDValue(value)
	self._fields.kdValue = self._fields.kdValue + value
	if self._fields.kdValue < 0 then
		self._fields.kdValue = 0
	end
end

function GObject:modifyKBValue(value)
	self._fields.kbValue = self._fields.kbValue + value
	if self._fields.kbValue < 0 then
		self._fields.kbValue = 0
	end
end

function GObject:modifyResistKd(value)
	self._fields.resistKd = self._fields.resistKd + value
end

function GObject:modifyResistKb(value)
	self._fields.resistKb = self._fields.resistKb + value
end

function GObject:isKnockDown()
	return self._fields.kdValue >= self._fields.resistKd
end

function GObject:isKnockBack()
	return self._fields.kbValue >= self._fields.resistKb
end

function GObject:resetKDValue()
	self._fields.kdValue = 0
	self._kd.time = 0
end

function GObject:resetKBValue()
	self._fields.kbValue = 0
	self._kb.time = 0
end

function GObject:getBackTime()
	return 0.5
end

function GObject:getBackSpeed()
	return self._fields.backSpeed
end

function GObject:pos(x,y)
	if x and not y then
		self._fields.pos = clone(x)
	elseif x and y then
		self._fields.pos = cc.p(x,y)
	end
	return clone(self._fields.pos)
end

function GObject:speed(x,y)
	if x and not y then
		self._fields.speed = clone(x)
	elseif x and y then
		self._fields.speed = cc.p(x,y)
	end
	return clone(self._fields.speed)
end

function GObject:size(w,h)
	if w and not h then
		self._fields.size = clone(w)
	elseif w and h then
		self._fields.size = cc.size(w,h)
	end
	return clone(self._fields.size)
end

function GObject:dir(x,y)
	if x and not y then
		self._fields.direction = clone(x)
	elseif x and y then
		self._fields.direction = cc.p(x,y)
	end
	return clone(self._fields.direction)
end

function GObject:getBox()
	 local pos = self._fields.pos
	 local size = self._fields.size
	 local rect = cc.rect(pos.x-size.width/2,pos.y+self._fields.height,size.width,size.height)
	 return rect
end

function GObject:setName(name)
	self._fields.name = name
end

function GObject:addCommand(type)
	self._commands[#self._commands+1] = type
end

function GObject:setDir(dir)
	--if not self._cmdDir.dst then
		--self:addCommand(object.cmd.dir)
	--end
	self._cmdDir.dst = dir
end

function GObject:canTurn()
	return self:canAttack()
end

function GObject:onChangeDir()
	if self._cmdDir.dst and self:canTurn() then
		self:onChangeDirFunc(self:dir(self._cmdDir.dst))
		self._cmdDir.dst = nil
	end
end

function GObject:attack()
	if self:canAttack() == false then return false end
	if self._attk.combo <= 3 then
		self._attk.combo = self._attk.combo + 1
		self:addCommand(object.cmd.attk)
	end
	
	return true
end

function GObject:ready()
	self._attkstate = attk.ready
end

function GObject:finishAttk()
	self:ready()
	self._attk.combo = 1
	self._attk.cur = 1
end

function GObject:canAttack()
	--cclog("attack state :%d",self._attkstate)
	return self._attkstate == attk.ready 
end

function GObject:canCost()
	return self._skillstate == sk.perpare
end

function GObject:prepareSkill()
	self._skillstate = sk.prepare
end

function GObject:startSkill()
	self._skillstate = sk.start
end

function GObject:SkillEnd()
	self._skillstate = sk.finish
end

function GObject:isSkillStart()
	return self._skillstate == sk.start
end

function GObject:isSkillFinish()
	return self._skillstate == sk.finish
end

function GObject:onAttack()
	if self:canAttack() then
		self:onAttackFunc(self._attk.cur)
		self._attk.cur = self._attk.cur + 1
		self._attkstate = attk.anybody
		return true
	end
	return false
end

function GObject:onSkill(skill)
	if self:canCast() then
		self:onSkillFunc(skill)
		return true
	end
	return false
end

function GObject:_update(dt)
	if self:dead() then
		self:onDead()
	end
	self:recoverKb(dt)
	self:recoverKd(dt)
	self:execute()
	self:update(dt)
end

function GObject:recoverKb(dt)
	if self._fields.kbValue > 0 then
		self._kb.time = self._kb.time + dt
		if self._kb.time - 0.2 >= 0 then
			self._kb.time = self._kb.time - 0.2
			self:modifyKBValue(-self._fields.recoverKb)
			if self._fields.kbValue == 0 then
				self._kb.time = 0
			end
		end
	end
end

function GObject:recoverKd(dt)
	if self._fields.kdValue > 0 then
		self._kd.time = self._kd.time + dt
		if self._kd.time - 0.2 >= 0 then
			self._kd.time = self._kd.time - 0.2
			self:modifyKDValue(-self._fields.recoverKd)
			if self._fields.kdValue == 0 then
				self._kd.time = 0
			end
		end
	end
end

function GObject:onAttackFunc(attk)
	cclog("override me GObject:onAttackFunc")
end

function GObject:onChangeDirFunc()
	cclog("override me GObject:onChangeDirFunc")
end

function GObject:onSkillFunc(skill)
	cclog("override me GObject:onSkillFunc")
end

function GObject:onKnockDown()
	cclog("override me GObject:onKnockDown")
end

function GObject:onKnockBack()
	cclog("override me GObject:onKnockBack")
end

function GObject:onDead()
	cclog("override me GObject:onDead")
end

function GObject:update(dt)
	cclog("override me GObject:update")
end

function GObject:execute()
	self:onChangeDir()
	if self:isKnockDown() then
		self:onKnockDown()
		self:resetKDValue()
	end
	if self:isKnockBack() then
		self:onKnockBack()
		self:resetKBValue()
	end
	if #self._commands > 0 then
		local command = self._commands[1]
		local ret = false
		if command == object.cmd.attk then
			ret = self:onAttack()
		else
			ret = self:onSkill(command)
		end
		if ret then
			table.remove(self._commands,1)
		end
	end
end

return GObject