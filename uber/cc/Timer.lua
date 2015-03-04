local Timer = class("Timer")
Timer.__index = Timer

function Timer:ctor(expiry)
	self._expiryTime = expiry
	self._scale = 1.0
	local scheduler = sharedDirector:getScheduler()
	self._schedulerId = scheduler:scheduleScriptFunc(handler(self,self.update),0,false)
end

function Timer:update(dt)
	self._expiryTime = self._expiryTime - (dt*1000 * self._scale)
	if self:Passed() then
		self:stop()
	end
end

function Timer:Passed()
	return self._expiryTime <= 0
end

function Timer:stop()
	if self._schedulerId then
		local scheduler = sharedDirector:getScheduler()
		scheduler:unscheduleScriptEntry(self._schedulerId)
		self._schedulerId = nil
	end
end

function Timer:getExpiry()
	return self._expiryTime
end

function Timer:setScale(scale)
	self._scale = scale
end

function Timer:getScale()
	return self._scale
end

function Timer:Reset(interval)
	if self:Passed() then
		local scheduler = sharedDirector:getScheduler()
		self._schedulerId = scheduler:scheduleScriptFunc(handler(self,self.update),0,false)
	end
	self._expiryTime = interval
end

return Timer