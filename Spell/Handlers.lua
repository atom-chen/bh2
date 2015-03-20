local effectMod = 
{
	damage = 1,			-- 伤害
	applyAura = 2,		-- 给予光环
	missile = 3,		-- 创建飞行道具
	trap	= 4,		-- 创建陷阱
}

local Handlers = 
{
	[effectMod.damage] = require 'Spell.handlers.damage',
	[effectMod.applyAura] = require 'Spell.handlers.applyAura',
	[effectMod.missile] = require 'Spell.handlers.createMissile',
	[effectMod.trap] = require 'Spell.handlers.createTrap',
}

return Handlers