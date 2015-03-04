local GameAI = class("GameAI")
GameAI.__index = GameAI

function GameAI:ctor(ctrl)
	self._timer = {}
	self._ctrl = ctrl
end


function GameAI:setCtrl(ctrl)
	self._ctrl = ctrl
	self:Launch()
end

function GameAI:update(dt)
	self:updateAI(dt)
end

--------------------------------------------------------
-- public function
--------------------------------------------------------

-- 计时开始
-- @param key 		计时器的标签,可以是数字,字符串,甚至是table,建议不使用table
-- @param expiry	计时时间 单位ms

function GameAI:TimerStart(key,expiry)
	if self._timer[key] then
		--cclog("重置AI timer:"..key)
		self._timer[key]:Reset(expiry)
	else
		self._timer[key] = uber.Timer.new(expiry)
	end
end

-- 查询计时是否结束
-- @param key 		需要查询的计时器标签,同上个函数
-- @retrun boolean	

function GameAI:TimerPassed(key)
	local timer = self._timer[key]
	if timer then
		return timer:Passed()
	else
		--cclog("没有找timer:"..key)
		return true
	end
end
---------------------------------------------------------
-- override function
---------------------------------------------------------

-- AI的重写更新函数
-- @param dt 帧与帧的间隔时间,单位:秒,类型float

function GameAI:updateAI(dt)
	cclog("override me updateAI")
end


function GameAI:Launch()

end 

-- 进入视野-敌对目标
function GameAI:MoveInLineOfSight(unit) 
end

return GameAI
