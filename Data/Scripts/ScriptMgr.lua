--ScriptMgr
local ScriptMgr = class("ScriptMgr")
ScriptMgr.__index = ScriptMgr


function ScriptMgr:ctor()
	self._gameLogic = nil
	self._controlMgr = nil

	self._timer = {}

	self._ChapterScripts = nil
end

function ScriptMgr:setGameLogic(gamelogic)
	assert(gamelogic)
	self._gameLogic = gamelogic
end


function ScriptMgr:loadChapterScript(filename)
	self._ChapterScript = require(filename..".lua")

	cclog("script filename:%s",filename)
	assert( self._ChapterScript )
	self._ChapterScript:setScript(self)
end

function ScriptMgr:unloadChapterScript(filename)
	self._ChapterScript = nil
end

function ScriptMgr:getChapter()
	assert( self._ChapterScript )
	return self._ChapterScript
end

function ScriptMgr:update(dt)
	
	if 	self._ChapterScript then
		self._ChapterScript:update(dt)
	end
end
--------------------------------------
-- 脚本调用接口
-- Creature 模块
--------------------------------------
-- 得到生物
function ScriptMgr:Creature(guid)
	local c = self._gameLogic:sGetCreature(guid)

	if( c == nil ) then
		cclog("SCRIPT ERROR:Creature guid '%d' not exist.::ScriptMgr:Creature",guid)
		assert(c)
	end
		
	return c
end

-- 创建生物
-- 脚本主动创建的生物GUID必须在10000-1000000之间
function ScriptMgr:Creature_Create(guid,entry)
	if ( guid<10000 or guid >1000000) then
		cclog("SCRIPT ERROR:guid '%d' must between 10000 to 100000,CreateCreature",guid)
		return 
	end

	if (self._gameLogic:sGetCreature(guid) ~=nil) then 
		cclog("SCRIPT ERROR:guid '%d' exist,CreateCreature",guid)
		return 
	end
	self._gameLogic:sCreateCreature(guid,entry)
end	

-- 销毁生物
function ScriptMgr:Creature_Destroy(guid)
	self._gameLogic:sRemoveCreature()
end

-- 将生物加入地图交互
function ScriptMgr:Creature_Add(guid,x,y,face,ai)
	self._gameLogic:sAddCreature(guid,x,y,face,ai)
end

-- 生物直接移动
function ScriptMgr:Creature_GotoXY(guid,x,y)
	local c = self:Creature(guid)
	local pos = cc.p(x,y)
	c:goto(pos,c:speed(),nil)
end

-- 查询生物是否死亡
-- 如果死亡返回true,否则false
function ScriptMgr:Creature_Dead(guid)
	local c = self:Creature(guid)
	return c:isDead()
end

-- 注册死亡处理回调
-- 在怪物死亡状态设置前调用
function ScriptMgr:Creature_RegDeadHandler(guid,handler)
	local c = self:Creature(guid)
	c:RegisterDeadFunc(handler)
end

--------------------------------------
-- 脚本调用接口
-- Player 模块
---------------------------------------
-- 调用主角
function ScriptMgr:Hero()
	return self._gameLogic._map:getPlayer(1)
end

function ScriptMgr:Hero_Pos()
	return self:Hero():pos()
end


--------------------------------------
-- 脚本调用接口
-- Map 关卡 模块
---------------------------------------
-- 调用本地图
function ScriptMgr:Map()
	assert(self._gameLogic._map)
	return self._gameLogic._map
end

-- 段完成
-- 段完成时调用,会解锁下一段
function ScriptMgr:Part_Complate()
	self._gameLogic:sEventPartComplate()
end
--------------------------------------
-- 脚本调用接口
-- MessageBox 模块
---------------------------------------
function ScriptMgr:MessageBox(str)
	self._gameLogic._map._uiLayer:addLabel1(str)
end

function ScriptMgr:MessageBox1(str)
	self._gameLogic._map._uiLayer:addLabel2(str)
end

--------------------------------------
-- 脚本调用接口
-- 计时器模块
-- @param key 		计时器的标签,可以是数字,字符串,甚至是table,建议不使用table
-- @param expiry	计时时间 单位ms
---------------------------------------
function ScriptMgr:Timer_Start(key,expiry)
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
function ScriptMgr:Timer_Passed(key)
	local timer = self._timer[key]
	if timer then
		return timer:Passed()
	else
		cclog("SCRIPT ERROR: Invaild Timer Key:%d ::TimerPassed",key)
		return true
	end
end

-- 充值计时器为0
function ScriptMgr:Timer_Reset(key)
	local timer = self._timer[key]
	if timer then
		self._timer[key]:Reset(0)
	else
		cclog("SCRIPT ERROR: Invaild Timer Key:%d ::TimerReset",key)
		return true
	end
end

-- 场景物体脚本调用
-- 添加陷阱
function ScriptMgr:AddTrap(effect)
	self._gameLogic:addTrap(nil,effect)
end

return ScriptMgr

