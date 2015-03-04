--[[
local Registry = require 'uber.helper.Registry'

local EventMgr = class("EventMgr",Registry)
EventMgr.__index = EventMgr

BaseEvent = require 'Event.BaseEvent'

function EventMgr:ctor()
	self.super.ctor(self,BaseEvent)
end

EventMgr = EventMgr.new()

RegisterEvent = function(evt)
	return EventMgr:add(evt)
end

ADD_EVENT = function(evt)
	local cls = EventMgr:get(evt)
	if not cls then
		require ('Event.'..evt)
		return ADD_EVENT(evt)
	else
		return cls.new()
	end
end

return EventMgr
]]
require 'Event.BaseEvent'
ADD_EVENT = function()
	return clone(BaseEvent)
end