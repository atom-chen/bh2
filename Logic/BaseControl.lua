local BaseControl = class("BaseControl")
BaseControl.__index = BaseControl

function BaseControl:ctor()
	self._players = {}
	self._objects = {}
end

function BaseControl:ConvertTo(otherControl)
	for _,v in ipairs(self._players) do
		otherControl:addPlayer(v)
	end
	for _,v in ipairs(self._objects) do
		otherControl:addObject(v)
	end
	self:clear()
end

function BaseControl:setUI(uiNode)
	self._ui = uiNode
	self:initControlUI()
end

function BaseControl:initControlUI()
	--assert(false)
end

function BaseControl:releaseControlUI()
	--assert(false)
end

function BaseControl:update(dt)
	--cclog("Control update")
end

function BaseControl:clear()
	cclog("Control clear")
	self._players = {}
	self._objects = {}
end

function BaseControl:addPlayer(player)
	self._players[#self._players+1] = player
	if #self._players == 1 then
		self._controller = player
	end
end

function BaseControl:addObject(object)
	self._objects[#self._objects+1] = object 
end

function BaseControl:OnFinishAddPlayers()
end

function BaseControl:ClickOn(pt)
	cclog("Control ClickOn")
end

function BaseControl:ClickEnd(pt)
	cclog("Control ClickEnd")
end

function BaseControl:drag(pt)
	cclog("Control drag")
end

function BaseControl:refreshUI()
end

return BaseControl