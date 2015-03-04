local EditorNode = class("EditorNode",function()
	return cc.Node:create()
	end)
EditorNode.__index = EditorNode

function EditorNode:ctor(c)
	self._drawNode = cc.DrawNode:create()
	self._opos = uber.p(0,0)
	self._epos = uber.p(50,50)
	self._color = c or cc.c4f(0,1.0,0,1.0)
	self:addChild(self._drawNode)
	self:DrawRect()
end

function EditorNode:setOPos(p)
	self._opos = p
	self._drawNode:setVisible(false)
end

function EditorNode:setEPos(p)
	self._epos = p
	self:DrawRect()
end

function EditorNode:setColor(c,redraw)
	self._color = c
	if redraw then
		self:DrawRect()
	end
end

function EditorNode:DrawRect()
	self._drawNode:clear()
	self._drawNode:setVisible(true)
	self._drawNode:drawRect(self._opos,self._epos,self._color)
end

function EditorNode:getSize()
	local sub = cc.pSub(self._opos,self._epos)
	if sub.x < 0 then
		sub.x = sub.x*-1
	end
	if sub.y < 0 then
		sub.y = sub.y*-1
	end
	local rs = cc.size(x,y)   -- 实际像素大小
	local ds = uber.size(x,y) -- 设计像素大小
	return rs,ds
end

return EditorNode