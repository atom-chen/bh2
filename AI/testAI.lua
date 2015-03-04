MotionTarget = require "AI.MotionTarget"


local testAI = RegisterAI("testAI")

CreatureBirthPos = cc.p(400,100)	-- 怪物初始位置
CreatureLaunchPos = cc.p(200,100)	-- 怪物启动后移动到的位置
CreatureLaunchSpeed = cc.p(420,360)		-- 启动移动速度
CreatureLaunchMode = 1
CreatureSightRange = 1000		-- 怪物视野范围
CreatureAttackRange = 100


local TIMER_KEY_1 = 3000

function testAI:Launch()
--	self._ctrl:setPos(CreatureBirthPos)
--	self._ctrl:goto(CreatureLaunchPos,CreatureLaunchSpeed,nil)

	self:TimerStart(1,3000)

end 

function testAI:MoveInLineOfSight(unit) 

end

function testAI:updateAI(dt)
	if self:TimerPassed(1) then 
		local pl = self._ctrl:getThreatMgr():getMostNearly()
		local attack = false
		if  pl and  
			(math.abs( self._ctrl:pos().x - pl:pos().x ) <= 200 and 
				math.abs( self._ctrl:pos().y - pl:pos().y ) <= 30) then
			 self._ctrl:attack()
			 self._ctrl:attack()
			 self._ctrl:attack()
			 attack = true
		end

		if pl and not attack and  
			(math.abs( self._ctrl:pos().x - pl:pos().x ) > 200 or 
				math.abs( self._ctrl:pos().x - pl:pos().x ) > 30) then
		
			local pos = self:FindNearlyPos(pl)
			self:MoveTo(pos)
		end

		self:TimerStart(1,3000)
	end
end

function testAI:FindNearlyPos(pl)
	local pos = cc.p(0,0)
	if self._ctrl:pos().x > pl:pos().x then
		pos.x =  pl:pos().x + CreatureAttackRange
	elseif self._ctrl:pos().x <= pl:pos().x then
		pos.x =  pl:pos().x - CreatureAttackRange
	end
	pos.y = pl:pos().y
	return pos
end

function testAI:MoveTo(pos)
	if self._ctrl:getMotionMgr():empty() then
		local mt = MotionTarget.new(1,self._ctrl)
		mt:SetTargetPos(pos, CreatureLaunchSpeed)
		self._ctrl:getMotionMgr():add(mt,false)
	end
end
