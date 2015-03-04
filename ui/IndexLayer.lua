local IndexLayer = class("IndexLayer",
	function()
		--local layer = cc.CSLoader:createNode("ui/Formation_zh.csb")--ccui.loadLayer("ui/Index")
		local layer = cc.CSLoader:createNode("ui/res/MainScene.csb")
		local action = cc.CSLoader:createTimeline("ui/res/MainScene.csb")
		action:gotoFrameAndPlay(0,false)
		layer:runAction(action)
		--layer:setNodeEventEnabled(true)
		--layer:setContentSize(cc.size(config.width,config.height))
		--ccui.Helper:doLayout(layer)
		return layer
	end
)

IndexLayer._loginLayer = nil
IndexLayer._regLayer = nil

function IndexLayer:ctor()
	self:setNodeEventEnabled(true)

	--self:AutoScale()
end

function IndexLayer:AutoScale()
    for i = 1,self:getChildrenCount() do
        local child = self:getChildren()[i]
        if child:getName() ~= "Image_bg" then
        	child:pos(display.p(child:pos()))
        else
        	display:AutoScale(child)
        end
    end
    
end

function IndexLayer:AnonymloginCallback()
	local AnonymAccount = PlatformUtility:getAnonymAccount()
	if AnonymAccount ~= "" then
		if string.sub(AnonymAccount,1,8) == "UBERAUTO" then 
			local psw = "000000"
		    network.SetUserNameAndPassWord(AnonymAccount,psw)
			local send_packet = WorldPacket:new(CMD_AUTH_LOGON_CHALLENGE_2,160)
		    send_packet:setStr("zhCN")
			send_packet:setStr(AnonymAccount)
			--send_packet:setStr("000000")
			network.send(send_packet)
			createFunnelLayer()
			cclog("AnonymAccount detected,Login")
		else
			PlatformUtility:setAnonymAccount("")
			cclog("匿名帐号被篡改，清空")
            return
		end
	else
		local send_packet = WorldPacket:new(CMD_CREATE_ANONYMOUS_ACCOUNT,60)
		if cc.platform == "windows" then
			local macAddress = PlatformUtility:GetDeviceMacAddress()
			send_packet:setStr(macAddress)
		else
			local ifa = PlatformUtility:GetDeviceIdentify()
			send_packet:setStr(ifa)
		end
		network.send(send_packet)	
	end
end

function IndexLayer:DirectloginCallback()
	local nameStr = PlatformUtility:getAccount()
    local pswStr = PlatformUtility:getPassword()
    if nameStr == "" then return end

	ACCOUNT = nameStr
	network.SetUserNameAndPassWord(nameStr,pswStr)
	local AnonymAccount = PlatformUtility:getAnonymAccount()
	if AnonymAccount == "" then 
		local send_packet = WorldPacket:new(CMD_CREATE_ANONYMOUS_ACCOUNT,60)
		if cc.platform == "windows" then
			local macAddress = PlatformUtility:GetDeviceMacAddress()
			send_packet:setStr(macAddress)
		else
			local ifa = PlatformUtility:GetDeviceIdentify()
			send_packet:setStr(ifa)
		end
		network.send(send_packet)
		createFunnelLayer()
	else
		local send_packet = WorldPacket:new(CMD_AUTH_LOGON_CHALLENGE_2,160)
		send_packet:setStr("zhCN")
		send_packet:setStr(nameStr)
		network.send(send_packet)
		createFunnelLayer()
	end	
end

function IndexLayer:wayToEnter()
	--[[
	local nameStr = self:getChild("Label_Username")
	if nameStr:getString() == "" then
		self:AnonymloginCallback()
	else
		self:DirectloginCallback()
	end]]
	UIMgr:EnterScene(GameState.MAIN)
end

function IndexLayer:LogoutCallback() 
	local nameStr = self:getChild("Label_Username")
    local btnLogin = self:getChild("Button_Login")
	local btnLoginout = self:getChild("Button_LoginOut")
	local textFrame = self:getChild("Image_3_0_1_0")
	local btnEnter = self:getChild("Image_Enter")
	if nameStr:getString() ~= "" then
		PlatformUtility:setAccount("")
        PlatformUtility:setPassword("")
		nameStr:setString("")
		btnLoginout:setVisible(false)
    	btnLoginout:setTouchEnabled(false)
    	btnLogin:setVisible(true)
    	btnLogin:setTouchEnabled(true)
    	textFrame:setVisible(false)
	end
end

function IndexLayer:showLoginCallback()
	if not self._loginLayer then
		self._loginLayer = require("UI.Login").new()
		self:addChild(self._loginLayer)
	else
		self._loginLayer:setVisible(true)
	end
end

function IndexLayer:ShowRegister( ... )
	self._loginLayer:setVisible(false)

	if not self._regLayer then
		self._regLayer = require("UI.Register").new()
		self:addChild(self._regLayer)
	else
		self._regLayer:setVisible(true)
	end
end


return IndexLayer