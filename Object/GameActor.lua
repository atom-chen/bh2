local sceneObject = require("Object.SceneObject")
local GameActor = class("GameActor",sceneObject)

function GameActor:ctor(json,atlas)
	--self.super.ctor(self)
	local armature = sp.SkeletonAnimation:create(json,atlas)
	self._armature = armature
	self:addChild(armature)
	self:setNodeEventEnabled(true)

	self._curAnimation = ""
	self:mix("stand","walk",0.2)
	self:mix("walk","stand",0.2)
	--self:mix("stand","attack1",0.2)
	--self:mix("attack1","attack2",0.2)
	--self:mix("attack2","attack3",0.1)
	--self:mix("attack1","stand",0.1)
	--self:mix("attack2","stand",0.1)
	--self:mix("attack3","stand",0.1)
	self._callback = 
	{
		[sp.EventType.ANIMATION_START] = {},
		[sp.EventType.ANIMATION_END] = {},
		[sp.EventType.ANIMATION_COMPLETE] = {},
		[sp.EventType.ANIMATION_EVENT] = {},
	}

	self:RegisterActor(sp.EventType.ANIMATION_START,handler(self,self.onStart))
	self:RegisterActor(sp.EventType.ANIMATION_END,handler(self,self.onEnd))
	self:RegisterActor(sp.EventType.ANIMATION_COMPLETE,handler(self,self.onComplete))
	self:RegisterActor(sp.EventType.ANIMATION_EVENT,handler(self,self.onEvent))

	
end


function GameActor:setMap( map )
	self._map = map
end

function GameActor:onEnter()
	local size = self._armature:getSize()
	--cclog("w:"..size.width.." h:"..size.height)
end

function GameActor:play(actor,loop,time,evtType,callback)
	self._armature:setAnimation(0,actor,loop)
	time = time or 1
	self._armature:setTimeScale(time)
	self._curAnimation = actor
	if evtType and callback then
		self:setCallBack(actor,callback,evtType)
	end
end

function GameActor:mix(from,to,duration)
	self._armature:setMix(from,to,duration)
end

function GameActor:getBox()
	return self._armature:getBoundingBox()
end

function GameActor:setDir(dir)
	local scale = self:getScaleX()
	if (dir.x > 0 and scale < 0) or (dir.x < 0 and scale > 0) then
		self:setScaleX(-scale)
	end
end

function GameActor:FadeOut(t,callback)
	local fadeOut =	cc.FadeOut:create(t)
	if callback then
		local seq = cc.Sequence:create(fadeOut,cc.CallFunc:create(callback))
		self._armature:runAction(seq)
	else
		self._armature:runAction(fadeOut)
	end
end

function GameActor:setCallBack(actor,func,type)
	if not self._callback[type] then
		assert(false,"type is out of range :%d",type)
		return
	end
	self._callback[type][actor] = func
end

function GameActor:onStart(spineEvent)
	local func = self._callback[sp.EventType.ANIMATION_START][self._curAnimation]
	if func then
		func(spineEvent)
	end
end

function GameActor:onComplete(spineEvent)
	local func = self._callback[sp.EventType.ANIMATION_COMPLETE][self._curAnimation]
	if func then
		func(spineEvent)
	end
end

function GameActor:onEnd(spineEvent)
	local func = self._callback[sp.EventType.ANIMATION_END][self._curAnimation]
	if func then
		func(spineEvent)
	end
end

function GameActor:onEvent(spineEvent)
	--cclog("onEvent "..spineEvent.animation .. " eventType:"..spineEvent.eventData.name)
	local func = self._callback[sp.EventType.ANIMATION_EVENT][self._curAnimation]
	if func then
		func(spineEvent)
	end
end

function GameActor:RegisterActor(type,func)
	self._armature:registerSpineEventHandler(func,type)
end

function GameActor:unRegisterActor(type)
	self._armature:unregisterSpineEventHandler(type)
end

return GameActor

