local Registry = require 'uber.helper.Registry'

local AIManager = class("AIManager",Registry)
AIManager.__index = AIManager

GameAI = require 'AI.GameAI'

function AIManager:ctor()
	self.super.ctor(self,GameAI)
end

AIManager = AIManager.new()

RegisterAI = function(ai)
	return AIManager:add(ai)
end

GET_AI = function(ai)
	local cls = AIManager:get(ai)
	if not cls then
		require ('AI.'..ai)
		return GET_AI(ai)
	else
		return cls.new()
	end
end

return AIManager