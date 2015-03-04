local mainLayer = class("mainLayer",function ()
	return ccui.layer()
end)

local RED = cc.c4f(1.0,0,0,1.0)

function mainLayer:ctor()
	--[[
	local bg = cc.Sprite:create("river.jpg")
	self:addChild(bg)
	bg:pos(cc.CENTER)

	local quit = cc.Sprite:create("button_quit.png")
	self:addChild(quit)
	quit:pos(uber.p(50,100))

	local ga = require("Object.GameActor").new("yns4/yns_4.json","yns4/yns_4.atlas")
	self:addChild(ga)
	ga:pos(uber.p(200,200))
	]]
	self:setLayerEventEnabled(true)
	self._drawNode = cc.DrawNode:create()
	self:addChild(self._drawNode)
	self._beginPos = uber.p(0,0)
	--self._drawNode:drawRect(uber.p(100,100),uber.p(200,200),RED)
end

function mainLayer:onTouchBegan(x,y)
	self._beginPos = cc.p(x,y)
	self._drawNode:setVisible(false)
	return true
end

function mainLayer:onTouchMoved(x,y)
	self._drawNode:setVisible(true)
	self._drawNode:clear()
	self._drawNode:drawRect(self._beginPos,cc.p(x,y),RED)
end

function mainLayer:onTouchEnded(x,y)
	self._drawNode:clear()
	self._drawNode:drawRect(self._beginPos,cc.p(x,y),RED)
end

return mainLayer