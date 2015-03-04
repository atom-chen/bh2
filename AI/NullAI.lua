MotionTarget = require "AI.MotionTarget"


local NullAI = RegisterAI("NullAI")

CreatureBirthPos = cc.p(400,100)	-- 怪物初始位置
CreatureLaunchPos = cc.p(200,100)	-- 怪物启动后移动到的位置
CreatureLaunchSpeed = cc.p(420,360)		-- 启动移动速度
CreatureLaunchMode = 1
CreatureSightRange = 1000		-- 怪物视野范围
CreatureAttackRange = 50


local TIMER_KEY_1 = 3000

function NullAI:Launch()
	self:TimerStart(1,3000)
end 

function NullAI:MoveInLineOfSight(unit) 

end

function NullAI:updateAI(dt)
	
end

function NullAI:FindNearlyPos(pl)

end

function NullAI:MoveTo(pos)

end
