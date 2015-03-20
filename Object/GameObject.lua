local Unit = require 'Object.Unit'
local GameObject = class("GameObject",Unit)
GameObject.__index = GameObject

function GameObject:ctor(guid,info,gtype)
	gtype = ObjectType or gtype
	Unit.ctor(self,guid,info,gtype)
end

function GameObject:update(dt)
end

return GameObject