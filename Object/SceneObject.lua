local SceneObject = class("SceneObject", function()
	return cc.Node:create()
end)
SceneObject.__index = SceneObject

function SceneObject:ctor()
	--self:setDrawBound(false)
	self:setSize(uber.size(50,50))
	self:setAnchorPoint(cc.p(0.5,0))
end

return SceneObject