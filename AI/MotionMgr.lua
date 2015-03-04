local  MotionMgr = class("MotionMgr")
MotionMgr.__index = MotionMgr

local vector = require "Common.vector"


function MotionMgr:ctor()
	self._list  = vector.new()

end

function MotionMgr:add(motion,stopCurrentMotion)

	if stopCurrentMotion then 
		self._list:back():stop()
		self._list:pop_back()
	end

	self._list:push_back(motion)
	motion:start()
end

function MotionMgr:update()
	if not self._list:empty() and self._list:back():complate() then
		self._list:pop_back()
		if not self._list:empty() then 
			self._list:back():start()
		end 
	end
end

function MotionMgr:empty()
	return self._list:empty()
end

return MotionMgr

