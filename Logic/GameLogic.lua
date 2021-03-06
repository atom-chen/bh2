SpellManager = require("Spell.SpellManager").new()
local ScriptMgr = require 'Data.Scripts.ScriptMgr'.new()
SpellManager:load()
require 'Object.ObjectManager'

local Unit = require 'Object.Unit'
local Creature = require 'Object.Creature'
local Player = require 'Object.Player'
local Missile = require 'Object.Missile'
local Trap = require 'Object.Trap'
local ItemObject = require 'Object.ItemObject'

local GuidMaker = require 'Logic.GuidMaker'

DamageType = 
{
	combat = 1, 	-- 近战
	flame = 2,		-- 火焰
	lightning = 3,	-- 雷电
	ice = 4,		-- 冰
	holy = 5,		-- 神圣
	darkness = 6,	-- 暗影
}

BattleLog = BattleLog or
{
	damage = 0,
	damageType = 0,
	healing = 0,
	spellId = 0,
}

PartFlag = 
{
	waitBegin = 0,
	normal = 1,
	ended = 2,
	waitNewPart = 3,
}

GameLogic = GameLogic or {}

GameLogic._flag = PartFlag.waitBegin

function AddMonster(id,x,y,face,ai)
	x = x or 50
	y = y or 100
	face = face or faceright

	require 'AI.AIManager'
	ai = ai or GET_AI("testAI")
	local idx = GameLogic:addMonster(id,x,y,face,ai)
	local monster = GameLogic:getMonster(idx)
	return monster,idx
end

function AddPlayer(id,x,y,face,ai)
	x = x or 50
	y = y or 100
	face = face or faceright
	ai = ai
	local idx = GameLogic:addPlayer(id,x,y,face,ai)
	local player = GameLogic:getPlayer(idx)
	return player,idx
end

function AddMissile(effect,caster,ai)
	local missile,idx = GameLogic:addMissile(effect,caster,ai)
	return missile,idx
end

function AddTrap(caster,effect)
	local trap,idx = GameLogic:addTrap(caster,effect)
	return trap,idx
end

function GameLogic:init(stage,chapter,section) --id:section id
	
	self._events = {}
	self._players = {}
	self._monsters = {}
	self._items = {}		-- 掉在地上的道具
	self._missiles = {}		-- 飞在场景内的导弹
	self._traps = {}		-- 场景内的陷阱
	self._objects = {}		-- 可破坏的场景物件

	self._playerGM = GuidMaker.new()
	self._monstersGM = GuidMaker.new()
	self._itemsGM = GuidMaker.new()
	self._missilesGM = GuidMaker.new()
	self._trapsGM = GuidMaker.new()
	self._objectsGM = GuidMaker.new()

	-- 设置脚本管理器
	ScriptMgr:setGameLogic(self)

	self:InitMap(stage,chapter,section)
	
	local scheduler = sharedDirector:getScheduler()
	self._schedulerId = scheduler:scheduleScriptFunc(handler(self,self.update),0,false)

	--设置掉落管理器
	ItemLootMgr:setGameLogic(self)
end

function GameLogic:InitMap( stage,chapter,section  )
--	self._curStage,self._curChapter,self._curSectionIdx,self._curPartIdx = nil,nil,nil,nil
--	self._curStage,self._curChapter,self._curSectionIdx = stage or 1,chapter or 1,section or 1
--	self._curSection = StageManager:getSection(self._curStage,self._curChapter,self._curSectionIdx)
	
	-- 临时代码,加载1-1关
	self:LoadFromDbc(1,1)

	local bRenewMap = false
	if self._map then 
		bRenewMap = true

		for k,monster in pairs(self._monsters) do
			cclog("------release monster")
			monster:Exit()
		end

		self._map:removeFromParent()
	end
	self._map = require("ui.GameMap").new() 
	self._map:LoadUI(self._curSection._file)

	if bRenewMap then
		local scene = sharedDirector:getRunningScene()
		scene:addChild(self._map)
		for k,player in pairs(self._players) do
			cclog("------map add player")
			player:createActor()
			player:setPos(cc.p(100,100))
			self._map:addSceneObject(player)
			player:stand()
			player:setMap(self._map)
		end
		ControlManager:setType(ControlType.keyboard,self._map._uiLayer)
	end

	------------------
	-- 设置摄像头
	-- 设置默认摄像头数据
	local rect = self._curSection:getWalkableRect()
	self._map:getCameraMgr():setSectionLimit(rect.x,rect.x+rect.width)
	self._map:getCameraMgr():setPartLimit(rect.x,rect.x+rect.width)


	-- 临时测试代码--------------------
	self:unlockPart(10101)
	--self:unlockPart(10102)
	--self:unlockPart(10103)
	--self:unlockPart(10104)
	
	--ControlManager:setType(ControlType.base)
	ControlManager:setType(ControlType.keyboard)

	--local id = self:addPlayer(1,100,100,faceleft)
	
	local player = AddPlayer(1,100,100,faceleft)
	--player:goto(uber.p(300,200),cc.p(420,300))
	--self._map:addPlayer(player,1)
	--AddMonster(1,500,200,faceleft)

	--------------------------------
--	self:enterPart()

	-- 执行脚本读取
	ScriptMgr:getChapter():Load()
end

function GameLogic:partEnd( )
--[[	
	if self._flag == PartFlag.ended then
		self._flag = PartFlag.waitNewPart
		if not self._curSection._parts[self._curPartIdx + 1] then
			--已经是最后一个Part就返回
			return
		end
		if ControlManager._type ~= ControlType.base then
			ControlManager:setType(ControlType.base,self._map._uilayer)

			--人物移动屏幕中间，地图移动到可移动范围中间，两者都移动完毕后，人物才可以动
			self._map:setLockRange(cc.rect(0,0,1920,640))
			self._map:moveToCenter(1)
			local player = ControlManager._ctrl._controller
			player:moveToCenter(1)
		end
		
	elseif self._flag == PartFlag.waitNewPart then
		self:enterPart()
	end
	]]
end

function GameLogic:enterPart()
--[[
	self._curPartIdx = self._curPartIdx or 0
	local curPart = self._curSection._parts[self._curPartIdx]
	if curPart then
		local player = ControlManager._ctrl._controller
		if player:pos().x >= curPart._checkPoint then
			self._curPartIdx = self._curPartIdx + 1
		else
			--还未走到通关检测点
			return
		end
	else
		--当前段为空，说明刚要开始刷第一段
		self._curPartIdx = self._curPartIdx + 1

		self._flag = PartFlag.waitBegin
	end
	
	local nextPart = self._curSection._parts[self._curPartIdx]
	if nextPart then
		cclog("-----------------------------")
		cclog("------开启段:"..self._curPartIdx)
		self._flag = PartFlag.normal
		for k,event in ipairs(nextPart._events) do
			self:addEvent(event)
		end
		self._map:setLockRange(nextPart._lockRect)

		self._map:setCheckPointPos(nextPart._checkPoint)
	else
		cclog("本节已经通关")
		self:enterNextSection()
	end
	]]
end

function GameLogic:enterNextSection( )
	--[[
	self._curSectionIdx = self._curSectionIdx + 1
	if StageManager:getSection(self._curStage,self._curChapter,self._curSectionIdx) then
		cclog("将进入下一节")
		self:InitMap(self._curStage,self._curChapter,self._curSectionIdx)
	else
		cclog("无下一节，GameLogic Exit")
		self:Exit()
	end
	]]
end

function GameLogic:addPlayer(id,x,y,face,ai)
	local info = ObjectManager:getInfo(id)
	local guid = self._playerGM:AutoGet()
	local player = Player.new(guid,info)
	-- 更新视野
	self:updateVisableFor(player)
	self._players[guid] = player
	player:addToWorld(self._map,cc.p(x,y),face,ai)
	ControlManager:addPlayer(player)
	return guid
end

function GameLogic:setMapLock(block)
	self._map:seLock(block)
end

function GameLogic:getPlayer(idx)
	return self._players[idx]
end

function GameLogic:getPlayerCount()
	return #self._players
end

function GameLogic:addMissile(effect,caster,ai)
	local spell = effect._spell
	local displayId = spell.displayID
	local displayEntry = sSpellDisplayStore[displayId]
	local guid = self._missilesGM:AutoGet()
	local missile = Missile.new(displayEntry.misc,effect._info.value_base,caster)
	self:updateVisableFor(missile)
	self._missiles[guid] = missile
	local pos = caster:pos()
	local face = caster:getFace()
	missile:addToWorld(self._map,pos,face,ai)
	ControlManager:addObject(missile)
	return missile,guid
end

function GameLogic:addTrap(caster,effect)
	local guid = self._trapsGM:AutoGet()
	local trap = Trap.new(guid,4,effect,caster)
	self:updateVisableFor(trap)
	self._traps[guid] = trap
	local pos = cc.p(200,200)
	local face = faceright
	if caster then
		pos = caster:pos()
		face = caster:getFace()
	end
	trap:addToWorld(self._map,pos,face,nil)
	ControlManager:addObject(trap)
	return tarp,guid
end

function GameLogic:addItem(id,caster)
	local guid = self._itemsGM:AutoGet()
	--local entry = sItemStore[id]
	--local display = sSpineStore[entry.display]
	local item = ItemObject.new(guid,id)
	self._items[guid] = item
	local pos = caster:pos()
	local face = caster:getFace()
	item:addToWorld(self._map,pos,face,nil)
	ControlManager:addObject(item)
	return item,guid
end

function GameLogic:removeItem(guid)
	local item = self._items[guid]
	if item then
		item:removeFromWorld()
		ControlManager:removeObject(item)
	end
	self._items[guid] = nil
end

function GameLogic:getObject(guid)
	return self._objects[guid]
end

function GameLogic:addMonster(id,x,y,face,ai)
	local guid = self._monstersGM:AutoGet()
	local info = ObjectManager:getInfo(id)
	local monster = Creature.new(info)
	self:updateVisableFor(monster)
	self._monsters[guid] = monster
	monster:addToWorld(self._map,cc.p(x,y),face,ai)
	ControlManager:addObject(monster)
	return guid
end

function GameLogic:getMonster(guid)
	return self._monsters[guid]
end

function GameLogic:addEvent(evt)
	self._events[#self._events+1] = evt
	--evt:start(self)
end

function GameLogic:update(dt)
	--self:checkPart()
	self:updateEvents(dt)
	-- 临时判断条件
	if self._map ~= nil then
		ScriptMgr:update(dt)
	end
	self:updateUnits(self._players,dt)
	self:updateUnits(self._monsters,dt)
	self:updateUnits(self._missiles,dt)
	self:updateUnits(self._traps,dt)
	self:updateItems(dt)
end

function GameLogic:updateUnits(units,dt)
	local removeList = {}
	for guid,unit in pairs(units) do
		if unit:isInWorld() then
			if unit:hasState(state.dead) then
				unit:removeFromWorld()
				removeList[#removeList+1] = guid
			else
				unit:_update(dt)
			end
		end
	end

	--for _,guid in pairs(removeList) do
	--	units[guid] = nil
	--end
end

function GameLogic:updateItems(dt)
	local ctrl = ControlManager:getController()
	if not ctrl then return end
	local pt = ctrl:pos()
	local pickUp_items = {}
	for guid,item in pairs(self._items) do
		if item:isInWorld() then
			item:update(dt)
			local rect = item:getBox()
			if cc.rectContainsPoint(rect,pt) then
				pickUp_items[#pickUp_items+1] = guid
			end
		end
	end

	for _,guid in pairs(pickUp_items) do
		self:removeItem(guid)
	end
end

function GameLogic:updateEvents(dt)
	if self._flag == PartFlag.waitBegin then
		return
	end

	local count = #self._events

	if count == 0 then
		if self._flag == PartFlag.normal then
			self._flag = PartFlag.ended
		end
		self:partEnd()
	end

	local idx = 1
	while idx < count+1
		do
			local evt = self._events[idx]
			if evt:isStart() then
				evt:start(self)
				break
			elseif evt:isRunning() then
				break
			elseif evt:Closed() then
				evt:onClosed()
				table.remove(self._events,idx)
				count = count - 1
			elseif evt:isUpdate() then
				evt:update(dt)
				break
			else
				idx = idx+1
			end
	end
end

function GameLogic:removeObject()
end

function GameLogic:Exit()
	self._map:removeFromParent()
	local scheduler = sharedDirector:getScheduler()
	scheduler:unscheduleScriptEntry(self._schedulerId)
end

function GameLogic:updateVisableFor(pl)
	for k,player in pairs(self._players) do
		player:updateVisableFor(pl)
		pl:updateVisableFor(player)
	end

	for k,monster in pairs(self._monsters) do
		monster:updateVisableFor(pl)
		pl:updateVisableFor(monster)
	end

	for k,object in pairs(self._objects) do
		object:updateVisableFor(pl)
		--pl:updateVisableFor(object)
	end 
end



-------------------------------------------------------------
-- load data
-------------------------------------------------------------
function GameLogic:LoadFromDbc(stageId,chapterId)
	self._curStage = stageId
	self._curChapter = chapterId
	
	local chapter = StageManager:getChapter(stageId,chapterId)
	self._curSectionIdx = chapter:getEntry().default_section

	if chapter:getEntry().script ~= "" then	
		ScriptMgr:loadChapterScript(chapter:getEntry().script)
	end


	-- 得到节数据
	self._curSection = StageManager:getSection(self._curStage,self._curChapter,self._curSectionIdx)
	self._curSection:setDefaultPart( self._curSection:getEntry().default_part)

	
	-- 得到段数据
	self._curPartIdx = self._curSection:getPart(self._curSection:getEntry().default_part):getId()

	
end

-------------------------------------------------------------
-------------------------------------------------------------
local Part = require 'Data.Part'

-------------------------------------------------------------
-------------------------------------------------------------
function GameLogic:unlockPart(id)
	self._curSection:unlockPartFromId(id)
	self._map:setLockRange( self._curSection:getWalkableRect() )

	local rect = self._curSection:getWalkableRect()
	self._map:getCameraMgr():setPartLimit(rect.x,rect.x+rect.width)
end

function GameLogic:sEventPartComplate()
	cclog("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!yuguiiuhhu:%d",self._curPartIdx )

	local partid = self._curSection:getNextPartId(self._curPartIdx)
	if( id ~= 0 ) then 
		self._curPartIdx = partid
		self:unlockPart(partid)
	end
end

-- 创建怪物
-- 每个脚本中必须指定怪物的GUID,并且不可重复
function GameLogic:sCreateCreature(guid,entry)
	local info = ObjectManager:getInfo(entry)
	local monster = Creature.new(guid,info)
	self._monsters[guid] = monster
end

function GameLogic:sDestroyCreature(guid)
	assert(self._monsters[guid])
	self._monsters[guid] = nil
end

function GameLogic:sAddCreature(guid,x,y,face,ai )
	local creature = self:sGetCreature(guid)
	self:updateVisableFor(creature)

	require 'AI.AIManager'
	ai = ai or "NullAI"
	ai = GET_AI(ai)
	creature:addToWorld(self._map,cc.p(x,y),face,ai)
	ControlManager:addObject(creature)
end

function GameLogic:sGetCreature(guid)
	return self._monsters[guid]
end