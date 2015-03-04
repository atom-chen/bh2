ControlManager = ControlManager or {}

ControlManager._controls = {}

ControlType = 
{
	base = 0,
	joystick = 1,
	keyboard = 2,
}

BaseControl = require("Logic.BaseControl")
JoystickControl = require('Logic.JoystickControl')
KeyBoardControl = require('Logic.KeyBoardControl')

Creator = 
{
	[ControlType.base] = BaseControl,
	[ControlType.joystick] = JoystickControl,
	[ControlType.keyboard] = KeyBoardControl,
}

ControlCreator = function(type)
	local func = Creator[type]
	if func then
		return func.new()
	else
		return nil
	end
end

function ControlManager:setType(type,UINode)
	UINode = UINode or GameLogic._map._uiLayer
	local lastCtrl = self._ctrl
	local ctrl = self._controls[type]
	if not ctrl then
		ctrl = ControlCreator(type)
		self._controls[type] = ctrl
	end

	if ctrl then
		if lastCtrl and lastCtrl ~= ctrl then
			lastCtrl:ConvertTo(ctrl)
			lastCtrl:releaseControlUI()
		end
		ctrl:setUI(UINode)
		ctrl:OnFinishAddPlayers()
		ctrl:refreshUI()
	end

	self._ctrl = ctrl

	self._type = type
	cclog("ControlManager._type:"..self._type)
end

function ControlManager:ClickOn(pt)
	if self._ctrl then
		self._ctrl:ClickOn(pt)
	end
end

function ControlManager:drag(pt)
	if self._ctrl then
		self._ctrl:drag(pt)
	end
end

function ControlManager:ClickEnd(pt)
	if self._ctrl then
		self._ctrl:ClickEnd(pt)
	end
end

function ControlManager:update(dt)
	if self._ctrl then
		self._ctrl:update(dt)
	end
end

function ControlManager:addPlayer(player)
	if self._ctrl then
		self._ctrl:addPlayer(player)
	end
end

function ControlManager:addObject(object)
	if self._ctrl then
		self._ctrl:addObject(object)
	end
end