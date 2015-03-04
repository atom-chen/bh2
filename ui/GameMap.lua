local GameMap = class("GameMap", function()
		return cc.LayerColor:create()
	end)
GameMap.__index = GameMap

require("Logic.ControlManager")
--[[
local MapProps = 
{
	Lock = 0,
	MoveSpeed = 0,
	StopSpeed = 0, --人物在地图一半的位置停止移动时，地图会有惯性移动，让人物最终停到屏幕的45%位置
	isBorder = 0,
	Offset = 0,
	Regions = 3, --区域数目，用于刷怪,刷怪期间处于锁屏状态
	State = {begin,story,pause,result},
	
}
]]

function GameMap:ctor()
	self:setLayerEventEnabled(true)
	-- add control ui
	-- 创建一个uilayer
 	self:LoadCSUI()

	self:scheduleUpdate()
	self._SceneObjects = {}
	self._Floor = nil

	self._timerShake = 0 			-- 震动计时器
	self._shakeDurtion = 0.05		-- 持续时间
	self._shakeCount = 0 			-- 震动次数
	self._shakeDisX = 0 			-- 震动位移X
	self._shakeDisY = 0 			-- 震动位移Y
	self._speed = cc.p(0,0)
	self._lockRect = cc.rect(0,0,1920,640)

	--[[
	local testBtn = ccui.image({image = "img_joystick.png"})
	testBtn:setTouchEnabled(true)
	testBtn:addTouchEvent({[ccui.TouchEventType.ended]= function () 
		GameLogic._events = {} 
	end})
	testBtn:pos(cc.p(winSize.width - 40,winSize.height - 40))
	self._uiLayer:addChild(testBtn)]]

	-- player位置
	self._playerLists = {}

	-- 摄像机数据
	self._cameraMgr = require("ui.CameraMgr").new()
	self._cameraMgr:init(self)

	self._cameramove = 0 -- 能否移动
	self._cameraS = 0
	self._cameraTime = 0
	self._cameraSrcPos = {x=0,y=0}
	self._cameraStep1Pos = {x=0,y=0}
	self._cameraStdScreenPos = {x=0,y=0}
	self._cameraDstS = 0
	self._cameraDstDir = 0

	self._cameraPlayerMoveTimer = 0
	self._cameraPlayerEvent = 0
			
end

function GameMap:LoadCSUI()
 	self._uiLayer = require("ui.MapUI").new()
 	self:addChild(self._uiLayer)
end

function GameMap:GetMapUI()
	return self._uiLayer
end

function GameMap:GetSpeed()
	return self._speed
end

function GameMap:SetSpeed(speed )
	self._speed = speed
end

function GameMap:ShakeUnderAttack()
	self:ScreenShake(1,1.5,0,0.02)
end
-- 地图屏幕震动对外接口
function GameMap:ScreenShake(n,distanceX,distanceY,durtion)
	self._shakeCount = 6
	self._shakeDurtion = durtion
	self._shakeDisX = distanceX
	self._shakeDisY = distanceY
end

function GameMap:updateShake(dt)
	if self._shakeCount > 0 then 
		self._timerShake = self._timerShake + dt
--[[
		if ( self._timerShake > self._shakeDurtion ) then

			local k = 1 		-- 计数器
			if self._shakeCount%2 == 1 then		
				k = -1
			end 

			self:shake(self._shakeDisX*k,self._shakeDisY*k)
			self._timerShake = 0
			self._shakeCount = self._shakeCount - 1
		end
]]

		local step = self._shakeCount
		local dur = self._shakeDurtion
		local x = 0
		local y = 0
		if( step == 6 ) then 
			dur = self._shakeDurtion
			x = -self._shakeDisX 
		elseif( step == 5 ) then 
			dur = self._shakeDurtion
			x = self._shakeDisX 
		elseif( step == 4 ) then 
			dur = self._shakeDurtion
			x = self._shakeDisX 
		elseif( step == 3 ) then
			dur = self._shakeDurtion
			x = -self._shakeDisX 
		elseif( step == 2 ) then
			dur = self._shakeDurtion / 3
			x = -self._shakeDisX / 2
		elseif( step == 1 ) then
			dur = self._shakeDurtion / 3
			x = self._shakeDisX / 2 
		end

		if ( self._timerShake > dur ) then
			self:shake(x,0)
			self._timerShake = 0
			self._shakeCount = self._shakeCount - 1
		end
	end
end 

function GameMap:shake(a,b)
	local x = self._Floor:getPositionX()
	local y = self._Floor:getPositionY()
	self._Floor:pos(x+a,y+b)

	--cclog("shake:%d,%d",a,b)
end

local function loadScene( filename )
	local json_str = sharedFileUtils:getStringFromFile(filename)--cc.HelperFunc:getFileData(filename)
	assert(json_str)
	local parseTable = cjson.decode(json_str)
	local scene = GameScene.new("scene",parseTable["width"])
	scene:serialize(parseTable)
	return scene
end

function GameMap:loadWidgets(filename) 
	local SceneManager = require("Editor.SceneEditor.Manager").new()
	filename = cc.getFullPath(filename)
	local scene = loadScene(filename)
    assert(scene,"Load Scene File:[" .. filename .. "] Fail")

    local pnode = cc.ParallaxNode:create()
    local visibleSize = winSize --cc.size(display._rw,display._rh)
    pnode:setContentSize(cc.size(tonumber(scene._width),winSize.height))
	local function createChild(ground)
		--local parallaxNode = cc.ParallaxNode:create()
		local retNode = nil
        for i=1,ground:LayerCount() do
		    local l = ground:getLayer(i-1)
		    local ratio = l._ratio
		    local zOrder = l._zOrder

		    local panel = ccui.panel()
		    panel:setTouchEnabled(true)
		    for j=1,l:getObjectCount() do
				local obj = l:getObject(j-1)
                local sprite = nil
                if not obj.PlistName then
					obj.Filename = "Res/" .. obj.Filename
				end
			    if string.find(obj.Filename,"%.plist") then 
			        sprite = ccui.particle(obj.Filename)
			    elseif string.find(obj.Filename,"%.ExportJson") then
			    	sprite = ccui.animationNode(obj.Filename)
			    elseif string.find(obj.Filename,"%.json") then
			    	sprite = ccui.spineNode(obj.Filename)
			    else
					if not obj.PlistName then
						sprite = ccui.image({image=obj.Filename,z=obj.zOrder})
					else
						local plistname = "Res/"..obj.PlistName
						plistname = string.gsub(plistname,"\\","/")
						cc.SpriteFrameCache:getInstance():addSpriteFrames(plistname)
						sprite = ccui.image({image=obj.Filename,loadType = 1, z=obj.zOrder})
					end
				end
				sprite:setScaleX(obj.Scale.x)
				sprite:setScaleY(obj.Scale.y)
				--display:AutoScale(sprite)
				sprite:pos(cc.p(obj.Pos))
				display:AutoScale(sprite)
				sprite:setFlippedX(obj.Flip.x)
				sprite:setFlippedY(obj.Flip.y)
				sprite:setRotation(obj.Rotation)
				sprite:setOpacity(obj.Opacity)
				if obj.Filter then
					obj.Filter:ApplyTo(sprite)
				end
				panel:addChild(sprite)
			end
			--display:AutoScale(panel)
            pnode:addChild(panel,0,ratio,{x=0,y=0})
            if i == ground:LayerCount() then
            	retNode = panel
            end
		end
		--pnode:addChild(parallaxNode,0,{x=1,y=1},{x=0,y=0})
		return retNode
	end
    createChild(scene._BackGround)
    self._Floor = createChild(scene._Floor)
    createChild(scene._FrontGround)

    return pnode
end

function GameMap:LoadUI(file)
	self._mapLayer = self:loadWidgets(file)
	assert(self._mapLayer,"nil layer")
	self:addChild(self._mapLayer,-1)

	--[[debug
	self._checkNode = cc.Node:create()
	self._bound = cc.DrawNode:create()
	self._bound:drawRect(cc.p(0,0),cc.p(80,80),cc.c4f(1.0,0,0,1.0))
	self._checkNode:addChild(self._bound)
	self._Floor:addChild(self._checkNode,1000000)]]
end

function GameMap:getFloorPos()
	return self._mapLayer:pos()
end

function GameMap:getMapWidth( )
	return self._mapLayer:getSize().width
end

function GameMap:getOffset()
	return self._mapLayer:getPositionX()
end

function GameMap:setCheckPointPos( p )
	--cclog("GameMap:setCheckPoint:%.2f",p)
	self._checkNode:pos(cc.p(p,winSize.height/2))
end

function GameMap:isRBorder()
	if self:getOffset() <= winSize.width - self._lockRect.width then
		return true
	end

	return false
end

function GameMap:isLBorder()
	if self:getOffset() >= 0 then
		return true
	end

	return false
end

function GameMap:moveToCenter(duration)
	--cclog("GameMap moveToCenter....................")
	duration = duration or 1

	local offset = 0
	local player = ControlManager._ctrl._controller
	if player:pos().x + self:getOffset() > winSize.width/2 then
		offset = 0 - (player:pos().x + self:getOffset() - winSize.width/2)
	else
		offset = 0--winSize.width/2 - (player:pos().x + self:getOffset())
	end
	cclog("move offset:"..offset/2)
	local posx = self._mapLayer:pos().x + offset/2
	local moveto = cc.MoveTo:create(duration,cc.p(posx,self._mapLayer:pos().y))
	local func = cc.CallFunc:create(function ()
		if ControlManager._type ~= ControlType.keyboard then
			cclog("ControlManager._type:"..ControlManager._type)
			cclog("---------set ControlType keyboard")
			ControlManager:setType(ControlType.keyboard,self._uiLayer)
		end
	end)
	self._mapLayer:runAction(cc.Sequence:create(moveto,func))
end

function GameMap:setLockRange( rect )
	--cclog("GameMap lockrect:%.2f,%.2f,%.2f,%.2f,",rect.x,rect.y,rect.width,rect.height)
	self._lockRect = rect or cc.rect(0,0,self._mapLayer:getSize().width,self._mapLayer:getSize().height)
end

function GameMap:setLock(block)
	self._lock = block or self._lock
end

function GameMap:isLock()
	return self._lock
end

function GameMap:updateMove(dt,dir)
	if self._lock then return end
	local pos = self._mapLayer:pos()
	local speed = self._speed
	pos.x = pos.x - speed.x * dt * dir.x * 60
	pos.y = pos.y
	self._mapLayer:pos(pos)

--	cclog("GAMEMAP:UPDATEMOVE:%d,%d",pos.x,pos.y)
--[[
	local monsters = GameLogic._monsters
	for i = 1,#monsters do
		local mPos = monsters[i]:pos()
		mPos.x = mPos.x + speed.x * dt * dir.x * 60
		monsters[i]:setPos(mPos)
	end
]]
end

function GameMap:onTouchBegan(x,y)
	--cclog("began x:"..x.." y:"..y)
	ControlManager:ClickOn(cc.p(x,y))
	return true
end

function GameMap:onTouchEnded(x,y)
	--cclog("ended x:"..x.." y:"..y)
	ControlManager:ClickEnd(cc.p(x,y))
end

function GameMap:onTouchMoved(x,y)
	--cclog("moved x:"..x.." y:"..y)
	ControlManager:drag(cc.p(x,y))
end

function GameMap:addSceneObject(object)
	self._SceneObjects[#self._SceneObjects+1] = object
	self._Floor:addChild(object._actor)
end

function GameMap:removeSceneObject(object)
	for idx,obj in ipairs(self._SceneObjects) do
		if obj == object then
			table.remove(self._SceneObjects,idx)
			self._Floor:removeChild(object._actor)
			return
		end
	end
end


-- 临时代码 创建玩家和怪物
--[[
玩家指针应该由谁创建和管理?应该有个角色层
怪物指针应该由谁创建和管理?应该是场景脚本
]]
function GameMap:createPlayer()
	
end
-- 临时代码结束
--------------------------------------------------------------



-- 添加玩家角色,1-4号位置
function GameMap:addPlayer(player,num)
	self._SceneObjects[#self._SceneObjects+1] = player
	self._Floor:addChild(player._actor)

	--assert(num>0 and num<=4)
	--assert( self._playerLists[num] == nil )

	self._playerLists[num] = player
end

-- 获得玩家角色,1-4号位置
function GameMap:getPlayer(num)
	--assert(num>0 and num<=4)
	pl = self._playerLists[num]
	--assert(pl)
	return pl
end

function GameMap:update(dt)
	ControlManager:update(dt)

	for _,object in ipairs(self._SceneObjects) do
		local z = winSize.height * 10 - math.modf(object:pos().y* 10)
		if object._actor:getLocalZOrder() ~= z then
        	self._Floor:reorderChild(object._actor,z)
        end
	end


	self:updateShake(dt)
--	self:CameraMoveA(1500,10,400,dt)

-------------------------------------------
--	local pl = self:getPlayer(1)
--	if pl then
--		local pos = pl:pos()
--		self._uiLayer:addLabel1("mx:"..pos.x..",my:"..pos.y)

--		local pos2 = pl:TransMapToScreen(pos)
--		self._uiLayer:addLabel2("scx:"..pos2.x..",scy:"..pos2.y)

--		local pos3 = pl._map._mapLayer:pos()
--		self._uiLayer:addLabel3("mapx:"..pos3.x..",mapy:"..pos3.y)
--	end

--	self:CameraUpdatePlayer(dt)
------------------------------
	self._cameraMgr:update(dt)
end

function GameMap:getCameraMgr()
	return self._cameraMgr
end
---------坐标转换 ----------------
function GameMap:CameraPos()
	local pos = {x=0,y=0}
	pos.x = -self:pos().x
	pos.y = -self:pos().y
end

function GameMap:CameraX()
	local pos = self._mapLayer:pos()
	pos.x = -pos.x
	return pos.x
end

---------摄像机处理 ----------------
-- 像素/秒
function GameMap:CameraSetSpeed(speed)
	self._cameraSpeed = speed
end

-- 直接移动地图坐标X
function GameMap:CameraSetMapX(x)
	local pos = self._mapLayer:pos()
	pos.x = -x
	pos.y = pos.y
	self._mapLayer:pos(pos)
end
----------------------------
-- 直接移动地图坐标S
-----------------------------
function GameMap:CameraMove(s)
	local pos = self._mapLayer:pos()
	pos.x = pos.x - s
	pos.y = pos.y
	self._mapLayer:pos(pos)
end




-- 匀速移动到地图坐标X
function GameMap:CameraMoveToMapX(x,v0,dt)
	local pos = self._mapLayer:pos()
	if math.abs( x + pos.x ) > 1 then
		if( -pos.x < x ) then
			pos.x = pos.x - dt * v0
			pos.y = pos.y
		else
			pos.x = pos.x + dt * v0
			pos.y = pos.y
		end 
		self._mapLayer:pos(pos)
	end
end

-- 加速移动到地图坐标X
function GameMap:CameraAccMoveToMapX(x,v0,a,dt)
	local s = 0
	local dir = 0
	if self._cameramove == 0 then
		self._cameraSrcPos = self._mapLayer:pos()

		self._cameraDstS = math.abs(x + self._cameraSrcPos.x)
		if x >= -self._cameraSrcPos.x then
			self._cameraDstDir = 1
		else
			self._cameraDstDir = -1
		end
		self._cameramove = 1
	end

	if self._cameramove == 1 then
		if( math.abs(self._cameraDstS) - math.abs(self._cameraS) >10 ) then
			self._cameraTime = self._cameraTime + dt
			self._cameraS = v0*self._cameraTime + a*self._cameraTime*self._cameraTime

			self._mapLayer:pos( cc.p(self._cameraSrcPos.x-self._cameraDstDir*self._cameraS,self._cameraSrcPos.y))
		else
			self._cameraS = 0
			self._cameraTime = 0
			self._cameramove = 2
			self._cameraDstS = 0
			self._cameraDstDir = 0
			return 1
		end	
	end

	return 0
end

function GameMap:CameraAccMoveToPlayer(dt)
	local pos = self:getPlayer(1):pos()
	self:CameraAccMoveToMapX( pos.x-winSize.width/2,300,10,dt)
end

function GameMap:CameraUpdatePlayer(dt)
	self._cameraPlayerMoveTimer = self._cameraPlayerMoveTimer + dt
	if self._cameraPlayerMoveTimer > 0.15 then
		local pos = self:getPlayer(1):pos()
		r = self:CameraAccMoveToMapX( pos.x-winSize.width/3,300,10,dt)

		if r== 1 then
			self._cameraPlayerMoveTimer = 0
			self._cameramove = 0
		end
	end
end

-- 直接移动
function GameMap:CameraMoveToXY()
	-- 现在玩家所在的地图位置
	local pMapPos = self:getPlayer(1):pos()

	local scpos = self:getPlayer(1):TransMapToScreen(pMapPos)

	pMapPos.x = winSize.width/2 - pMapPos.x
	pMapPos.y = self._mapLayer:pos().y
	
	self._uiLayer:addLabel4("x:"..pMapPos.x.."y:"..pMapPos.y)
	self._mapLayer:pos(pMapPos)
end

-- 匀速直线运动
function GameMap:CameraMoveTo(speed,dt)
	local pos = self._mapLayer:pos()
	pos.x = pos.x - dt * speed
	pos.y = pos.y
	self._mapLayer:pos(pos)

	cclog("CCCCC:%d,%d",pos.x,pos.y)
end

-- 加速直线运动
function GameMap:CameraMoveA(s,v0,a,dt,dir)
	if self._cameramove == 0 then
		self._cameraSrcPos = self._mapLayer:pos()
		self._cameramove = 1
	end
	--cclog("CCCCC:%d,%d",self._cameraSrcPos.x,self._cameraSrcPos.y)

	if self._cameramove == 1 then
		if( math.abs(self._cameraS) < math.abs(s)) then
			--cclog("<<<<<<<<<<")
			self._cameraTime = self._cameraTime + dt
			self._cameraS = v0*self._cameraTime + a*self._cameraTime*self._cameraTime

			self._mapLayer:pos( cc.p(self._cameraSrcPos.x+dir*self._cameraS,self._cameraSrcPos.y))
		else
			local pos = {x=self._cameraS,y=1}
			self._cameraS = 0
			self._cameraTime = 0
			self._cameramove = 2
			return pos
		end	
	end

	local pos = {x=0,y=0}
	return pos
end



-------------------------

return GameMap