
local Stage = require 'Data.Stage'
local Chapter = require 'Data.Chapter'
local Section = require 'Data.Section'
local Part = require 'Data.Part'
require 'Event.Manager'


local st1 = Stage.new(1,"第一关","第一关")
local chp1 = Chapter.new("")

local sec1 = Section.new()
local sec2 = Section.new("res/Scenes2/newScene.sce")

st1:addChapter(chp1)
chp1:addSection(sec1)
chp1:addSection(sec2)
---------------------------------------------------------
--- Part1
---------------------------------------------------------
local part1 = 0
local part2 = 0
local part3 = 0

local p1_evt1 = ADD_EVENT() --Part1的事件1
local C1 = {} --Part1的怪物列表

local evt2 = ADD_EVENT()

-- 创建段
local function OnCreatePart(sec1)
	part1 = Part.new(1)
	sec1:addPart(part1)
	part2 = Part.new(2)
	sec1:addPart(part2)
	part3 = Part.new(3)
	sec1:addPart(part3)
end

--检查所有的怪物是否死亡
local function CheckAllCreaturesDead( C )
	assert(type(C) == "table","传参不合法")
	for k,creature in pairs(C) do
		if creature:dead() == false then
			return false
		end
	end

	return true
end

function p1_evt1:onStart()
	ControlManager:setType(ControlType.base)
	local player = AddPlayer(1)
	player:goto(uber.p(300,200),cc.p(420,300),handler(self,self.onEnd))
end

function p1_evt1:onEnd()
	ControlManager:setType(ControlType.keyboard)
	--C1[1] = AddMonster(1,500,200,faceleft)
	self:toUpdate()
end

function p1_evt1:updateEvent(dt)
	--if C1[1]:dead() and not C1[2] then
		--C1[2] = AddMonster(1,500,200,faceleft)
		--return
	--end

	--if CheckAllCreaturesDead(C1) then
	--	self:close()
	--end
end

OnCreatePart(sec1)
part1:addEvent(p1_evt1)
part2:addEvent(evt2)

return st1