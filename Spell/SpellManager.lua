Spell = require("Spell.Spell")

local SpellManager = class("SpellManager")
SpellManager.__index = SpellManager

function SpellManager:ctor()
	self._spellInfo = {}
end

function SpellManager:load()
	self._spellInfo = sSpellEntry
end

function SpellManager:addInfo(info)
	self._spellInfo[info.id] = info
end

function SpellManager:getSpell(id)
	local info = self._spellInfo[id]
	local sp = nil
	if info then
	 	sp = Spell.new(info)
	end
	return sp
end

function SpellManager:getMove(name)
	for _,v in pairs(sSpellMoves) do
		if v.name == name then
			return v
		end
	end
	return nil
end

function SpellManager:getEffectEntry(id)
	return sSpellEffects[id]
end

return SpellManager