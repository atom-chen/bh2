local ItemObject = class("ItemObject",function() 
	return ccui.loadWidget("ui/Loot.csb")
	end)
BagDataMgr = require 'utils.manager.BagDataMgr'

function ItemObject:ctor(guid,id)
	self._guid = guid
	self._id = id
	self._type = ItemType
end

function ItemObject:addToWorld(map,pos,face,ai)
	local action = cc.CSLoader:createTimeline("ui/Loot.csb")
	action:gotoFrameAndPlay(0,false)
	action:setLastFrameCallFunc(handler(self,self.AnimationEnd))
	self:runAction(action)
	self._map = map
	self:pos(pos)
	self._actor = self
	self._map:addSceneObject(self)
	-- face ai 不需要
end

function ItemObject:getGuid()
	return self._guid
end

function ItemObject:getType()
	return self._type
end

function ItemObject:AnimationEnd()
	self._addToWorld = true
	--cclog("ItemObject AnimationEnd")
end

function ItemObject:isInWorld()
	return self._addToWorld
end

function ItemObject:removeFromWorld()
	self._map:removeSceneObject(self)
	self._addToWorld = false
	if self._bound then
		self:getParent():removeChild(self._bound)
	end

end

function ItemObject:getBox()
	local pos = self:pos()
	local box = self:getChild("Sprite_1"):getBoundingBox()
	box.x = pos.x - box.width/2
	box.y = pos.y
	return box
end

function ItemObject:update(dt)
	self._boundDirty = true
	if self._boundDirty then
		if not self._bound then
			self._bound = cc.DrawNode:create()
			self:getParent():addChild(self._bound,999)
		end
		local rect = self:getBox() 
		self._bound:clear()
		self._bound:drawRect(cc.p(rect.x,rect.y),cc.p(rect.x+rect.width,rect.height+rect.y),cc.c4f(0.2,0.9,0.1,1.0))
	end
end

return ItemObject