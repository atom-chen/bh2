local applyAura = function(effect,caster,target)
	target:addAura(effect._info,effect._spell._info.displayID)
end

return applyAura