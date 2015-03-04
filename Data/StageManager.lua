local Stage = require 'Data.Stage'
local Chapter = require 'Data.Chapter'
local Section = require 'Data.Section'
local Part = require 'Data.Part'


local StageManager = class("StageManager")
StageManager.__index = StageManager

function StageManager:ctor()
	self._stages = {}
end

function StageManager:addStages(id,stage)
	assert(stage,"invalid stage")
	--if not self._stages then self._stages = {} end
	self._stages[id] = stage
end

function StageManager:load()
	local loadStageCfg = require("Data.loadStageCfg") or {}
	for k,filename in pairs(loadStageCfg) do
		local stage = require(filename)
		assert(stage,"Load Stage File [".. filename .."] Fail")
		self:addStages(stage)
	end
end

function StageManager:loadfromdbc()
	for k,entry in pairs(sStageStore) do
		local stage = Stage.new()
		stage:LoadFromDbc(k)
		self:addStages(k,stage)
	end

	for k,entry in pairs(sChapterStore) do
		local chapter = Chapter.new()
		chapter:LoadFromDbc(k)
		self._stages[entry.stage_index]:addChapter(k,chapter)
	end

	for k,entry in pairs(sSectionStore) do
		local section = Section.new()
		section:LoadFromDbc(k)

		local chapterId = entry.chapter_index
		assert( sChapterStore[chapterId],"ERROR:Invalid chapterId in StageManager:loadfromdbc "..chapterId)
		local stageId = sChapterStore[chapterId].stage_index
		cclog("stageID "..stageId.." chapterId "..chapterId)
		local stage = self:getStage(stageId)
		local chapter = stage:getChapter(chapterId)

		chapter:addSection(k,section)
	end

	for k,entry in pairs(sPartStore) do
		local part = Part.new()
		part:LoadFromDbc(k)

		local sectionId = entry.section_index
		assert( sSectionStore[sectionId],"ERROR:Invalid sectionId in StageManager:loadfromdbc "..sectionId)
		
		local chapterId = sSectionStore[sectionId].chapter_index 
		assert( sChapterStore[chapterId],"ERROR:Invalid chapterId in StageManager:loadfromdbc "..chapterId)
		local stageId = sChapterStore[chapterId].stage_index

		local section = self:getStage(stageId):getChapter(chapterId):getSection(sectionId)

		section:addPart(k,part)
	end 

end

function StageManager:getStage(id)
--[[
	for _,stage in ipairs(self._stages) do
		if stage:getJsonData().id == tonumber(id) then
			return stage
		end
	end
]]
	local stage = self._stages[id]
	assert(stage,"ERROR:Invalid stageId in StageManager:getStage "..id)
	return stage
end

function StageManager:getChapter( stageId, chapteId)
	return self:getStage(stageId):getChapter(chapteId)
end

function StageManager:getSection( stageid,chapterid,sectionid )
	return self:getStage(stageid):getChapter(chapterid):getSection(sectionid)
end

return StageManager