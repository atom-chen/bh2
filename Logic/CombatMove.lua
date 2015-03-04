combatInfo = combatInfo or
{
	id = 0,
	name = "近战模板",
	type = spInfo.area,
	area = cc.rect(0,0,0,0),
	cost = {},		-- hp,mp
	target = {},
	camera = 0,
	kdvalue = 100, 
	kbvalue = 0,
	floating = 0,
	floating_time = 0,
	floating_height = 0,
	combo = 1,

	camera = 0,
	physics = 1,		-- 轻击
}

combat = combat or {}

combat.err = 
{
	ok = 0,
	cost_hp = 1,
	cost_mp = 2,
	out_of_range = 3,
}

combat.errStr =
{
	"hp不足",
	"mp不足",
	"超出射程",
}

local prepare = 0
local start = 1
local running = 2
local finish = 3
local failed = 4

local CombatMove = class("CombatMove")
CombatMove.__index = CombatMove

function CombatMove:ctor(info)
	self._caster = nil 		-- 施放者
	self._monster = {}
	self._friend = {}
	self._object = {}
	self._item = {}
	self._info = info
	self._err = combat.err.ok
	self._state = prepare
	self._damage = 0
	self._healing = 0
end

function CombatMove:start(caster,logic)
	self._caster = caster
	self._logic = logic
	self._caster:prepareSkill()
	if self:checkCost() == false then
		self._state = failed
	else
		self._state = start
	end
end

function CombatMove:checkCost()
	local ret = false
	if self._caster and self._info.cost then
		local hp = self._caster:getHp()
		local mp = self._caster:getMp()
		local cost_hp = self._info.cost.hp or 0
		local cost_mp = self._info.cost.mp or 0
		if hp <= cost_hp then
			self._err = combat.err.cost_hp
			return ret
		end
		if mp < cost_mp then
			self._err = combat.err.cost_mp
			return ret
		end
		ret = true
	end
	return ret
end

function CombatMove:getError()
	local err = combat.errStr[self._err]
	if err then
		return err
	else
		return ""
	end
end

function CombatMove:update(dt)
	if self:failed() then
		self._logic:castSpellFailed(self)
		return
	end
	if self._caster:isSkillStart() then
		self:pickTarget()
	end

	if self:running() then
		self:effect()
		self:checkFinish()
	end

	if self._state == finish then
		self._logic:finishSpell(self)
	end
end

function CombatMove:pickTarget()
	local logic = self._logic
	local caster = self._caster
	local monster = self._info.target.monster
	if monster then
		self._monster.effects = monster.effects
		monster = logic:getHostile(caster,monster.condition)
		self._monster.targets = monster
	end

	local friend = self._info.target.friend
	if friend then
		self._friend.effects = friend.effects
		friend = logic:getFriends(friend.condition)
		self._friend.targets = friend
	end

	local object = self._info.target.object
	if object then
		self._object.effects = object.effects
		object = logic:getObjects(object.condition)
		self._object.targets = object
	end

	local item = self._info.target.item
	if item then
		self._item.effects = item.effects
		item = logic:getItems(item.condition)
		self._item.targets = item
	end

	self._state = running
end

function CombatMove:getAreaRect()
	local rect = self._caster:getSpellArea()
	--self._caster:DrawEffectBound()
	if not rect then
		local pos = self._caster:pos()
		local area = self._info.area
		rect = cc.rect(area.x+pos.x,area.y+pos.y,area.width,area.height)
	end
	return rect
end

function CombatMove:effect()
	if self._monster.targets then
		for k,v in pairs(self._monster.targets) do
			if self:effectOnMonster(v) then
				self._monster.targets[k] = nil
			end
		end
	end
	-- friend
	-- object
	-- item
end

function CombatMove:effectOnMonster(monster)
	local ret = false
	if self:checkRange(monster) then
		for _,effect in pairs(self._monster.effects) do
			ret = effect:on(self,monster,self._caster)
			if ret == false then
				return ret
			end
		end
		monster:applyCombat(self)
	end
	return ret
end

function CombatMove:failed()
	return self._state == failed
end

function CombatMove:running()
	return self._state == running
end

function CombatMove:checkRange(target)
	local spType = self._info.type
	if spType == spInfo.target then
		return true	-- 暂时直接指向目标的技能还没有
	elseif spType == spInfo.area then
		local area = self:getAreaRect()
		local box = target:getBox()
		--cclog("spell area x:%.2f y:%.2f w:%.2f h:%.2f",area.x,area.y,area.width,area.height)
		--cclog("target x:%.2f y:%.2f w:%.2f h:%.2f",box.x,box.y,box.width,box.height)
		return cc.rectIntersectsRect(area,box)
	end
	return false
end

function CombatMove:checkFinish()
	if self._caster:isSkillFinish() then
		self._state = finish
		return
	end

	if self._monster.targets and #self._monster.targets > 0 then
		return
	end
	if self._friend.targets and #self._friend.targets > 0 then
		return
	end
	if self._object.targets and #self._friend.targets > 0 then
		return
	end
	if self._friend.targets and #self._friend.targets > 0 then
		return
	end
	--cclog("没有目标,技能结束")
	self._state = finish
end

return CombatMove