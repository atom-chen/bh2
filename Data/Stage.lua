local Stage = class("Stage")
Stage.__index = Stage

function Stage:ctor(id,name,desc,icon)
	self._entry = {}
	self._chapters = {}

	self._name = name or "关卡"
	self._desc = desc or "这是一个关卡"
	self._icon = icon or nil -- 缩略图,可能不需要
	self._id = id or 0
end

function Stage:LoadFromDbc(id)
	local entry = sStageStore[id]
	assert(entry,"ERROR:Invalid stageId in Stage:LoadFromDbc "..id)
	self._entry = entry
end

function Stage:getId()
	return self._entry.id
end

function Stage:getEntry()
	return self._entry
end

function Stage:addChapter(id,chapter)
	self._chapters[id] = chapter
end

function Stage:getChapter(id)
	local chapter = self._chapters[id]
	assert(chapter,"ERROR:Invalid chapterId in Stage:getChapter "..id)
	return chapter
end

function Stage:getJsonData()
	local data = {}
	data["Chapters"] = self._chapters
	data["name"] = self._name
	data["desc"] = self._desc
	data["icon"] = self._icon
	data["id"] = self._id
	return data
end

return Stage