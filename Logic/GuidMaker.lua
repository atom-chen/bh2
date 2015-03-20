local GuidMaker = class("GuidMaker")

function GuidMaker:ctor()
	self._guidList = {}
	self._maxGuid = 0
end

function GuidMaker:Get(guid)
	if self:exist(guid) then
		return false
	end
	self._guidList[guid] = true
	if guid > self._maxGuid then
		self._maxGuid = guid
	end
	return guid
end

function GuidMaker:AutoGet()
	local guid = self:Get(self._maxGuid+1)
	assert(type(guid) ~= "boolean")
	return guid
end

function GuidMaker:exist(guid)
	return self._guidList[guid] ~= nil
end

return GuidMaker