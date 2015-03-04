local CombatInfo = class("CombatInfo", function()
    return cc.LabelBMFont:create()
    --return cc.LabelAtlas:_create()
end)

function CombatInfo:ctor(victim,value,type,bCrit)
	assert(victim and value)
	--assert(value ~= 0)

	if type == DamageType.heal then
		self:initWithString(tostring(value), "font/font_heal.fnt")
		self:setScale(0.3)
	elseif type == DamageType.info then
		--应该是加Sprite:闪避，未命中，免疫。。。
		--self:addChild(ccui.image{image=""})
	else
		self:initWithString(tostring(value), "font/font_hurt.fnt")
		self:setScale(0.3)
	end

	self._parentScaleX = 1
	if victim:getScaleX() < 1 then
		self._parentScaleX = -1
	end
	self._parentScaleX = 1

	self:action1()
end

function CombatInfo:action()
	local scale
	if bCrit then
		scale = cc.ScaleTo:create(0.2,0.6);
	else
		scale = cc.ScaleTo:create(0.15,0.3); --0.15秒，文字大小变为70%
	end

	local move = cc.MoveBy:create(1,cc.p(0,200));
	local fadeout = cc.FadeOut:create(1);
	local easeOut = cc.EaseExponentialIn:create(scale);
	local sp = cc.Spawn:create(move,cc.Sequence:create(easeOut,fadeout));
	self:runAction(cc.Sequence:create(cc.DelayTime:create(1),sp,cc.CallFunc:create(function ()
		self:removeFromParent()
	end)))
end

function CombatInfo:action1()
	local temp = 0.3
	self:setScaleX(temp*self._parentScaleX)
	self:setScaleY(temp)
	local delay = cc.DelayTime:create(0.01)
	local func1 = cc.CallFunc:create(function () self:setScaleX(temp*3*self._parentScaleX);self:setScaleY(temp*3) end)
	local delay1 = cc.DelayTime:create(0.01)
	local scale = cc.ScaleTo:create(0.05,temp*0.5*self._parentScaleX,temp*0.5) --cc.CallFunc:create(function () self:setScaleX(0.5*0.7*self._parentScaleX);self:setScaleY(0.5*0.7) end)
	local delay2 = cc.DelayTime:create(0.05)
	local func2 = cc.CallFunc:create(function () self:setScaleX(temp*self._parentScaleX);self:setScaleY(temp) end)
	local delay3 = cc.DelayTime:create(0.2)
	local move = cc.MoveBy:create(0.5,cc.p(0,200));
	local fadeout = cc.FadeOut:create(0.3);
	local seq = cc.Sequence:create(delay,func1,delay1,scale,delay2,func2,delay3,cc.Spawn:create(move,fadeout),cc.CallFunc:create(function ()
		self:removeFromParent()
	end))
	self:runAction(seq)
end

return CombatInfo