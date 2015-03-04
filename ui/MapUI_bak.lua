local MapUI = class("MapUI",
	function ()
		return ccui.loadWidget("ui/BattleView_1.json")
	end
)

function MapUI:ctor()
	for i = 0,4 do
 		self:getChild("suiconghpkuang_"..i):setVisible(false)
 		self:getChild("img_monsterhead_"..i):setVisible(false)
 	end

 	self:autoscale()
end

function MapUI:autoscale()
	for i = 1,self:getChildrenCount() do
        local child = self:getChildren()[i]
        if child:getName() ~= "Image_bg" then
        	--display:ccp( child )
        	child:pos(display.p(child:pos()))
        else
        	display:AutoScale(child)
        end
    end
end

function MapUI:updateHp(hp,maxhp)
	hp = hp or 0
	maxhp = maxhp or 1
	assert(maxhp ~= 0,"max hp should not be 0")
	self:getChild("num_curhp"):setString(tostring(hp))
	self:getChild("num_hp"):setString(tostring(maxhp))
	self:getChild("bar_hp"):setPercent(hp/maxhp * 100)
end

function MapUI:UpdateMoney( money)
	self:getChild("num_money"):setString(tostring(money))
end

function MapUI:UpdateScroll(scroll )
	self:getChild("num__juanzhuo"):setString(tostring(scroll))
end

function MapUI:UpdateExp(exp,maxexp)
	self:getChild("num_curexp"):setString(tostring(curexp))
	self:getChild("num_exp"):setString(tostring(maxexp))
end

function MapUI:AddCombo(combo)
	combo = combo or 1
	--[[
	if not self._comboNode then
		self._comboNode = cc.CSLoader:createNode("combo.csb")
		self._comboNode:pos(winSize.width - self._comboNode:getContentSize().width,winSize.height/2)
		self:addChild(self._comboNode)
	end
	local action = cc.CSLoader:createTimeline("combo.csb")
	action:gotoFrameAndPlay(0,false)
	self._comboNode:runAction(action)
	self._comboNode:getChildByName("BitmapFontLabel_2"):setString(tostring(combo))]]

	if not self._comboNode then
		self._comboNode = cc.Node:create()

		local hit = ccui.image({image = "img_hits.png"})
		hit:setAnchorPoint(cc.p(0,0.5))
		local num = cc.LabelBMFont:create()
		num:setName("num")
		num:setAnchorPoint(cc.p(1,0))
		num:initWithString(tostring(combo), "font/font_hurt.fnt")

		self._comboNode:addChild(num)
		self._comboNode:addChild(hit)
		self:addChild(self._comboNode)
		self._comboNode:pos(winSize.width - 150,winSize.height/2 + 100)

		self._comboNode.hit = hit
		self._comboNode.num = num
	end

	self._comboNode:getChildByName("num"):setString(tostring(combo))

	--self._comboNode:setScale(1.5)
	self._comboNode.hit:setScale(1.2)
	self._comboNode.num:setScale(1.2)
	self._comboNode.hit:setOpacity(255)
	self._comboNode.num:setOpacity(255)
	local scale = cc.ScaleTo:create(0.2,1)
	local scale1 = cc.ScaleTo:create(0.2,1)
	local fade = cc.FadeOut:create(2)
	local fade1 = cc.FadeOut:create(2)
	local delay = cc.DelayTime:create(0.2)
	self._comboNode.hit:stopAllActions()
	self._comboNode.num:stopAllActions()
	self._comboNode.hit:runAction(cc.Sequence:create(delay,scale,fade))
	self._comboNode.num:runAction(cc.Sequence:create(delay,scale1,fade1))
	
	
end

function MapUI:addLabel1( str,pos )
	if not self.label1 then
		pos = pos or cc.p(300,winSize.height - 150)
		self.label1 = ccui.label({text=str})
		self:addChild(self.label1)
		self.label1:pos(pos)
	end
	self.label1:setString(tostring(str))
end

function MapUI:addLabel2( str,pos )
	if not self.label2 then
		pos = pos or cc.p(300,winSize.height - 180)
		self.label2 = ccui.label({text=str})
		self:addChild(self.label2)
		self.label2:pos(pos)
	end
	self.label2:setString(tostring(str))
end

function MapUI:addLabel3( str,pos )
	if not self.label3 then
		pos = pos or cc.p(300,winSize.height - 210)
		self.label3 = ccui.label({text=str})
		self:addChild(self.label3)
		self.label3:pos(pos)
	end
	self.label3:setString(tostring(str))
end

function MapUI:addLabel4( str,pos )
	if not self.label4 then
		pos = pos or cc.p(300,winSize.height - 240)
		self.label4 = ccui.label({text=str})
		self:addChild(self.label4)
		self.label4:pos(pos)
	end
	self.label4:setString(tostring(str))
end

return MapUI