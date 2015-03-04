local Chapter = class("Chapter")
Chapter.__index = Chapter

function Chapter:ctor(name,desc)
	self._sections = {}
	self._entry = {}
	self._name = name or "章节"
	self._desc = desc or "这是关卡下的一个章节"
	self._thumb = "" -- 缩略图,可能不需要
end

function Chapter:LoadFromDbc(id)
	local entry = sChapterStore[id]
	assert(entry,"ERROR:Invalid stageId in Chapter:LoadFromDbc "..id)
	self._entry = entry
end	

function Chapter:getId()
	return self._entry.id
end
function Chapter:getEntry()
	return self._entry
end

function Chapter:addSection(id,section)
	self._sections[id] = section 
end

function Chapter:getSection(id)
	local section = self._sections[id]
	assert(section,"ERROR:Invalid sectionId in Chapter:getSection "..id)
	return section
end

function Chapter:getJsonData()
	local data = {}
	data["Sections"] = self._sections
	data["name"] = self._name
	data["desc"] = self._desc
	return data
end

return Chapter