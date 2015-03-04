-- Chapter 1-1
require 'Data.Scripts.BaseChapterScript'

local ChapterScript = CREATE_CHAPTER_SCRIPT()

-- 地图事件定义
local event_part1_wave1 = 0
local event_part2_wave1 = 0
local event_part3_wave1 = 0


-- 地图怪物定义
local SC = 
{
	c1 = 10101,
	c2 = 10102,
	c3 = 10103,
	c4 = 10104,																		--zero定义了新怪物
	c5 = 10105,																		--zero定义了新怪物
	c6 = 10106,																		--zero定义了新怪物
	c7 = 10107,																		--zero定义了新怪物
	c8 = 10108,																		--zero定义了新怪物
	c9 = 10109,																		--zero定义了新怪物
}
-- 地图计时器定义
local timer_part2 = 5000															--zero定义了出怪计时器

-- 自定义变量


-- 读取地图
function ChapterScript:Load()
	self:script():Creature_Create(SC.c1,1)
	self:script():Creature_Create(SC.c2,1)
	self:script():Creature_Create(SC.c3,1)
	self:script():Creature_Create(SC.c4,1)
	self:script():Creature_Create(SC.c5,1)											--zero新加载了怪物
	self:script():Creature_Create(SC.c6,1)											--zero新加载了怪物
	self:script():Creature_Create(SC.c7,1)											--zero新加载了怪物
	self:script():Creature_Create(SC.c8,1)											--zero新加载了怪物
	self:script():Creature_Create(SC.c9,1)											--zero新加载了怪物

--	self:script():Creature_Create(c3)
end

-- 创建段
function ChapterScript:InitPart()
	
end

-- 更新
function ChapterScript:update(dt)
	-- 显示坐标
	local pos = self:script():Creature(SC.c1):pos()
	self:script():MessageBox("x:"..pos.x.." y:"..pos.y)

	pos = self:script():Creature(SC.c3):pos()
	self:script():MessageBox1("x:"..pos.x.." y:"..pos.y)

	-- 更新事件
	self:eventSpawn_Part1()
	self:eventCheckComplate_Part1()

	self:eventSpawn_Part2()
	self:eventSpawn2_Part2()														--zero新增段2事件2
	self:eventCheckComplate_Part2()													--zero新增段2结束条件

	self:eventSpawn_Part3()															--zero新增段3
	self:eventCheckComplate_Part3()													--zero新增段3结束条件
end

-- 进入场景
function ChapterScript:EnterChapter()

end

-- 退出场景
function ChapterScript:CloseChapter()
	
end

function ChapterScript:eventSpawn_Part1()
	if event_part1_wave1 == 0 then 
		self:script():Creature_Add(SC.c1,500,50,faceleft,"testAI")					--zero修改了坐标
		self:script():Creature_Add(SC.c2,550,200,faceleft,"testAI")					--zero修改了坐标
		event_part1_wave1 = 1 
	end

end

function ChapterScript:eventCheckComplate_Part1()
	if event_part1_wave1 ==  1 then

		if self:script():Creature_Dead(SC.c1) and 
			self:script():Creature_Dead(SC.c2) then
			self:script():Part_Complate()
			event_part1_wave1 = 2
		end
	end

end

function ChapterScript:eventSpawn_Part2()
	if event_part2_wave1 == 0 and self:script():Hero_Pos().x > 1000 then
		self:script():Timer_Start(timer_part2,5000) 								--zero新加载计时器
		self:script():Creature_Add(SC.c3,1500,50,faceleft,"testAI")					--zero修改了坐标
		self:script():Creature_Add(SC.c4,1500,200,faceleft,"testAI")				--zero新增了怪物
		self:script():Creature_GotoXY(SC.c3,1200,100)								--zero修改了坐标
		self:script():Creature_GotoXY(SC.c4,1200,150)								--zero为新增怪物增加移动行为 
		event_part2_wave1 = 1
	end
end

function ChapterScript:eventSpawn2_Part2()									--zero新增了段2结束条件声明
	if event_part2_wave1 == 1 then

		if self:script():Timer_Passed(timer_part2) then								--zero出怪计时器检查到期
		self:script():Creature_Add(SC.c5,500,100,faceright,"testAI")					--zero计时器到期出怪
		self:script():Creature_GotoXY(SC.c5,800,100)								--zero为新增怪物增加移动行为
		event_part2_wave1 = 2
		end
	end
end

function ChapterScript:eventCheckComplate_Part2()									--zero新增了段2结束条件声明
	if event_part2_wave1 == 2 then
		if self:script():Creature_Dead(SC.c3) and 
			self:script():Creature_Dead(SC.c4) and
			self:script():Creature_Dead(SC.c5) then
			self:script():Part_Complate()
			event_part2_wave1 = 3
		end
	end
end

function ChapterScript:eventSpawn_Part3()											--zero新增了段3声明
	if event_part3_wave1 == 0 and self:script():Hero_Pos().x > 1500 then
		self:script():Creature_Add(SC.c6,2000,100,faceleft,"testAI")
		self:script():Creature_GotoXY(SC.c6,1700,100)
		self:script():Creature_RegDeadHandler(SC.c6,handler(self,self.handlerDead))
		event_part3_wave1 = 1
	end
end

function ChapterScript:eventCheckComplate_Part3()									--zero新增了段2结束条件声明
	if event_part3_wave1 == 1 then

		if self:script():Creature_Dead(SC.c6) and 
			self:script():Creature_Dead(SC.c7) and
			self:script():Creature_Dead(SC.c8) then
			self:script():Part_Complate()
			event_part2_wave1 = 2
		end
	end
end

function ChapterScript:handlerDead()
	self:script():Creature_Add(SC.c7,2000,50,faceleft,"testAI")						--zero修改了坐标
	self:script():Creature_Add(SC.c8,1000,200,faceleft,"testAI")					--zero新增了怪物
	self:script():Creature_Add(SC.c9,1000,100,faceleft,"testAI")					--zero新增了怪物
	self:script():Creature_GotoXY(SC.c7,1700,150)									--zero修改了坐标
	self:script():Creature_GotoXY(SC.c8,1300,200)									--zero为新增怪物增加移动行为
	self:script():Creature_GotoXY(SC.c9,1300,100)									--zero为新增怪物增加移动行为
end

return ChapterScript