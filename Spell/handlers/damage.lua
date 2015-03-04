
local damage = function(effect,caster,target)
	local entry = effect._info
	local log = 
	{
		damageType = entry.damageType,
		damage = entry.value_base,
		spellId = effect._spell._info.id,
		valueMod = entry.valueMod,
		value_pct = entry.value_pct,
		hitback = entry.hitback,
		hitdown = entry.hitdown,
	}
	target:onHit(log)
	caster:combo()
end

return damage