local Part = class("Part")
Part.__index = Part

function Part:ctor(index,leftpos,rightpos) 
	self._events = {}
	self._entry = {}

	--lockRect:锁屏区域；checkRect:进入下一段的检测点
	if index == 1 then
		self._checkPoint = 900
		self._lockRect = cc.rect(0,0,960,250)
	elseif index == 2 then
		self._checkPoint = 1400
		self._lockRect = cc.rect(0,0,1440,250)
	elseif index == 3 then
		self._checkPoint = 1850
		self._lockRect = cc.rect(0,0,1920,250)
	else
		self._checkPoint = 900
		self._lockRect = cc.rect(0,0,960,250)
	end

	self._locked = true
	self._index = index
	self._leftPos = leftpos
	self._rightPos = rightpos
end

function Part:LoadFromDbc(id)
	local entry = sPartStore[id]
	assert(entry,"ERROR:Invalid sectionId in Part:LoadFromDbc "..id)
	self._entry = entry
end	

function Part:getId()
	return self._entry.id
end

function Part:getEntry()
	return self._entry
end

function Part:getLeftPos()
	return self._entry.leftpos
end

function Part:getRightPos()
	return self._entry.rightpos
end

function Part:getNextPartId()
	return self._entry.nextpart
end

function Part:addEvent(evt)
	self._events[#self._events+1] = evt
end

function Part:getJsonData()
	local data = {}
	data["Events"] = self._events
end

function Part:lock()
	self._locked = true
end

function Part:unlock()
	self._locked = false
end

function Part:locked()
	if self._locked == true then
		return true
	end

	return false
end


return Part