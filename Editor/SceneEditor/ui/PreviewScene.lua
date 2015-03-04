local PreviewScene = class("PreveiwScene", function()
	return cc.Scene:create()
end)
PreviewScene.__index = PreviewScene

function PreviewScene:ctor()
	self.psize = {width=0,height=0}   --记录场景宽高
	local keyshortcut = KeyBoardManager:getShortcuts("PreviewScene")
	if not keyshortcut then
		keyshortcut = KeyShortcuts.new("PreviewScene")
		KeyBoardManager:add(keyshortcut)
	end
	keyshortcut:add(single_type,"KEY_LEFT_ARROW",handler(self,self.onPressLeft),handler(self,self.onReleaseLeft))
	keyshortcut:add(single_type,"KEY_RIGHT_ARROW",handler(self,self.onPressRight),handler(self,self.onReleaseRight))
	keyshortcut:add(single_type,"KEY_UP_ARROW",handler(self,self.onUp),nil)
	keyshortcut:add(single_type,"KEY_DOWN_ARROW",handler(self,self.onDown),nil)
	keyshortcut:add(single_type,"KEY_ESCAPE",handler(self,self.returnEditor),nil)
	KeyBoardManager:apply("PreviewScene")
end


function PreviewScene:onPressLeft()
    self:scheduleUpdateWithPriorityLua(handler(self,self.onMoveLeft),1)
end

function PreviewScene:onReleaseLeft()
	self:unscheduleUpdate()
end

function PreviewScene:onPressRight()
	self:scheduleUpdateWithPriorityLua(handler(self,self.onMoveRight),1)
end

function PreviewScene:onReleaseRight()
    self:unscheduleUpdate()
end

function PreviewScene:onMoveLeft(dt)
	cclog(" PreviewScene:onLeft:"..tostring(self))
	local posx = self.parallaxNode:getPositionX() - 2000*tonumber(string.format("%.3f",dt))/60
	cclog("posx:"..posx)
	cclog("max value:"..-(tonumber(self.psize.width))/2)
	if posx <= -(tonumber(self.psize.width))/2 then posx = -(tonumber(self.psize.width))/2 end
	self.parallaxNode:setPositionX(posx)
end

function PreviewScene:onMoveRight(dt)
	cclog(" PreviewScene:onRight:"..tostring(self))
	local posx = self.parallaxNode:getPositionX() + 2000*tonumber(string.format("%.3f",dt))/60
	cclog("posx:"..posx)
	if posx >=0 then posx = 0 end
	--if posx 0 then posx 
	self.parallaxNode:setPositionX(posx)
end

function PreviewScene:onUp()
	local posy = self.parallaxNode:getPositionY() + 1
	self.parallaxNode:setPositionY(posy)
end

function PreviewScene:onDown()
	local posy = self.parallaxNode:getPositionY() - 1
	self.parallaxNode:setPositionY(posy)
end

function PreviewScene:returnEditor()
	--sharedDirector:getOpenGLView():setFrameSize(config.width,config.height)
	--sharedDirector:getOpenGLView():setDesignResolutionSize(config.designWidth,config.designHeight,config.policy)
	--self:removeAllChildren()
	cc.popScene()
	--self:removeAllChildrenWithCleanup(true)
	SceneManager:removeScene("newScene_preview")
	KeyBoardManager:apply("SceneEditor")
end

function PreviewScene:loadSce(filename,prevsize) 
	cclog("-------加载sce文件--------")
	--ProjectManager:prevload(filename)
    cclog("prevsize width:"..prevsize.width.." height:"..prevsize.height)
    local scene = SceneManager:prevLoad(filename)
    if not scene then return end
    local scenewidth = tonumber(scene._width)
	self.parallaxNode = cc.ParallaxNode:create()
	self.parallaxNode:setContentSize(cc.size(50,50))
	self.parallaxNode:setDrawBound(true)
    --self.parallaxNode:setContentSize(cc.size(scenewidth,prevsize.height))

	local function createChild(ground)
        for i=1,ground:LayerCount() do
        	--cclog(" ground layerCount:"..ground:LayerCount())
		    local l = ground:getLayer(i-1)
		    local ratio = l._ratio
		    local zOrder = l._zOrder

		    local panel = ccui.panel({size = prevsize})
		    --local node = cc.Node:create()
		    --panel:setTouchEnabled(true)
		    for j=1,l:getObjectCount() do
		    	--cclog(" l:getObjectCount:"..l:getObjectCount())
				local obj = l:getObject(j-1)
                local sprite = nil
                local objtype = -1
                if not obj.PlistName then
                	obj.Filename = ProjectManager._project.workpath .. "\\Res\\" .. obj.Filename
                end
			    if string.find(obj.Filename,"%.plist") then 
			        sprite = ccui.particle(obj.Filename)
			        objtype = 2
			    elseif string.find(obj.Filename,"%.ExportJson") then
			    	sprite = ccui.animationNode(obj.Filename)
			    	objtype = 3
			    elseif string.find(obj.Filename,"%.json") then
			    	sprite = ccui.spineNode(obj.Filename)
			    	objtype = 4
			    else
					if not obj.PlistName then
						sprite = ccui.image({image=obj.Filename,z=obj.zOrder})
					else
						local plistname = obj.PlistName
						plistname = string.gsub(plistname,"\\","/")
						--cc.SpriteFrameCache:getInstance():addSpriteFrames(plistname)
						sprite = ccui.image({image=obj.Filename,loadType = 1, z=obj.zOrder})
					end
					objtype = 0
				end
				cclog("sprite posx:"..obj.Pos.x.." y:"..obj.Pos.y)
				sprite:setScaleX(obj.Scale.x)
				sprite:setScaleY(obj.Scale.y)
				sprite:pos(uber.p(obj.Pos))
				sprite:setFlippedX(obj.Flip.x)
				sprite:setFlippedY(obj.Flip.y)
				sprite:setRotation(obj.Rotation)
				sprite:setOpacity(obj.Opacity)
				if obj.Filter then
					obj.Filter:ApplyTo(sprite)
				end
				panel:addChild(sprite)
				cclog("sprite size:"..sprite:getSize().width..","..sprite:getSize().height)
				
			end
			self.parallaxNode:addChild(panel,0,ratio,{x=0,y=0})
		end
	end
    createChild(scene._BackGround)
    createChild(scene._Floor)
    createChild(scene._FrontGround)
    --self.parallaxNode:pos(uber.p(winSize.width,winSize.height))

    self._layer = cc.Layer:create()
    --self._layer:addChild(self.parallaxNode)


local node = cc.ParallaxNode:create()
node:setContentSize(cc.size(50,50))
node:setDrawBound(true)
local image = ccui.image({image = "Res/bg.png"})
--image:setAnchorPoint(cc.p(0,0))
node:addChild(image,0,cc.p(1,1),cc.p(image:getSize().width/2,image:getSize().height/2))--cc.p(0,0))
self._layer:addChild(node)
    self:addChild(self.parallaxNode)
    
    --self.parallaxNode:setTouchEnabled(true)
    cclog("end")
end


return PreviewScene