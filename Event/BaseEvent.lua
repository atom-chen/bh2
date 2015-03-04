evt = 
{
	born = 0,
	start = 1,
	running = 2,
	update = 3,
	pause = 4,
	close = 5,
}

BaseEvent = BaseEvent or {}
BaseEvent.state = evt.start

function BaseEvent:start(logic)
	self._logic = logic
	self:Run()
	self:onStart()
end

function BaseEvent:isStart()
	return self.state == evt.start
end

function BaseEvent:isRunning()
	return self.state == evt.running
end

function BaseEvent:isUpdate()
	return self.state == evt.update
end

function BaseEvent:Closed()
	return self.state == evt.close
end

function BaseEvent:Run()
	self.state = evt.running
end

function BaseEvent:update(dt)
	self:updateEvent(dt)
end

------------------------------------------------------
-- public function
------------------------------------------------------

-- 进入Event的更新阶段
function BaseEvent:toUpdate()
	self.state = evt.update
end

-- 关闭Event
function BaseEvent:close()
	self.state = evt.close
end

-- 获得游戏逻辑
function BaseEvent:getLogic()
	return self._logic
end

-- 获得游戏UI层对象
function BaseEvent:getUI()
	return self._logic._map._uiLayer
end

------------------------------------------------------
-- override function
------------------------------------------------------

-- Event的可重写更新函数
function BaseEvent:updateEvent(dt)
	cclog("BaseEvent update")
	self:close()
end

-- Event开启时做的事情
function BaseEvent:onStart()
	cclog("BaseEvent onStart")
end

-- Event关闭时做的事情
function BaseEvent:onClosed()
	cclog("BaseEvent onClosed")
end

