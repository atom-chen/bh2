local Section = class("Section")
Section.__index = Section

function Section:ctor(file)
	self._file = file or "res/Scenes/newScene.sce" -- 对应的场景文件
	self._parts = {}
	self._entry = {}
	self._walkableRect = cc.rect(0,0,0,640)		-- 节内的可行走区域
	self._defaultPartId = 0							-- 进入节后默认的第一个段

	-- 注意这里需要导入这个地图的最大X坐标来确认行走区域的最大值
end

function Section:LoadFromDbc(id)
	local entry = sSectionStore[id]
	assert(entry,"ERROR:Invalid sectionId in Section:LoadFromDbc "..id)
	self._entry = entry
end	

function Section:getId()
	return self._entry.id
end

function Section:getEntry()
	return self._entry
end


function Section:addPart(id ,Part)
	self._parts[id] = Part 
	cclog("!!!!!!!Addpartid:%d",id)
end

function Section:getPart(partId)
	print("-----------------partId")
	--dump(self._parts)
	local part = self._parts[partId]
	assert(part,"ERROR:Invalid partId in Section:getPart "..partId)
	return part
end

-- 获得进入后的第一个段ID
function Section:getDefaultPartId()
	return self._defaultPartId
end

-- 设置第一个段
function Section:setDefaultPart(partId)
	local part = self:getPart(partId)
	self._defaultPartId = part:getId()
	self:unlockPart(part)
end

function Section:setWalkableRect(part)
	assert(part,"ERROR:Invaild Part in Section:setWalkableRect")

	local left = part:getEntry().leftpos
	local right =  part:getEntry().rightpos

	cclog("walkableRect:%d,%d,%d,%d",self._walkableRect.x,self._walkableRect.y,self._walkableRect.width,self._walkableRect.height)
	if left>=0 and left < self._walkableRect.x then
		self._walkableRect.x = left
		self._walkableRect.width = self._walkableRect.width+self._walkableRect.x-left
	else
		cclog("WARNING:Invalid left:%d in Section:setWalkableRect",left)
	end

	if right>self._walkableRect.x then
		self._walkableRect.width = self._walkableRect.width+right-self._walkableRect.width	
	else
		cclog("WARNING:Invalid right:%d in Section:setWalkableRect",right)
	end
end

function Section:getWalkableRect()
	return self._walkableRect
end

function Section:getJsonData()
	local data = {}
	data["file"] = self._file
	data["Parts"] = self._parts
end

function Section:getPartCounts()
	return #self._parts
end


function Section:getPrevPartId(currPartid)
	if currPartid <= 1 then
		return -1
	end

	return currPartid - 1 
end

function Section:getNextPartId(partId)
	print("Section:getNextPartId:"..partId)
	local part = self:getPart(partId)
	local id = part:getNextPartId()
	assert(self:getPart(id),"ERROR:Invaild Part in Section:getNextPartId")
	return id
end

function Section:unlockPart(part)
	assert(part,"ERROR:Invaild Part in Section:unlockPart")
	part:unlock() 
	self:setWalkableRect(part)
end

function Section:lockPart(part)
	assert(part,"ERROR:Invaild Part in Section:unlockPart")
	part:lock()
	-- 差关闭行走区域的代码
end

function Section:unlockPartFromId(partId)
	part = self:getPart(partId)
	self:unlockPart(part)
end

function Section:lockPartFromId(partId)
	part = self:getPart(partId)
	self:lockPart(part)
end

function Section:unlockNextPart(partId)
	local id = self:getNextPart(partId)
	if id < 0 then
		unlockPart(id)
	else
		cclog("WARNING:Invalid partId:%d in Section:unlockNextPart",partId)
	end
end


return Section