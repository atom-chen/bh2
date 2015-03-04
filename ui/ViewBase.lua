
local ViewBase = class("ViewBase", cc.Node)

function ViewBase:ctor(app, name)
    --self:enableNodeEvents()
    self.app_ = app
    self.name_ = name

    -- check CSB resource file
    local res = rawget(self.class, "RESOURCE_FILENAME")
    if res then
        self:createResoueceNode(res)
    end

    local binding = rawget(self.class, "RESOURCE_BINDING")
    if res and binding then
        self:createResoueceBinding(binding)
    end

    --if self.AUTOSCALE then
    --cclog("-----------1111111:"..rawget(self.class, "AUTOSCALE"))
    if rawget(self.class, "AUTOSCALE") then
        self:AutoScale()
    end

    if self.onCreate then self:onCreate() end
end

function ViewBase:getApp()
    return self.app_
end

function ViewBase:getName()
    return self.name_
end

function ViewBase:getResourceNode()
    return self.resourceNode_
end

function ViewBase:getPanel()
    return self.resourceNode_:getChild("Panel") or self.resourceNode_
end

function ViewBase:AutoScale()
    cclog("--------ViewBase:AutoScale()")
    local node = self:getPanel()
    for i = 1,node:getChildrenCount() do
        local child = node:getChildren()[i]
        if child:getName() ~= "Image_bg" then
            child:pos(display.p(child:pos()))
        else
            display:AutoScale(child)
        end
    end
    
end

function ViewBase:createResoueceNode(resourceFilename)
    cclog("createResoueceNode,resourceFilename:"..resourceFilename)
    if self.resourceNode_ then
        self.resourceNode_:removeSelf()
        self.resourceNode_ = nil
    end
    if CCS_VER < 2 then
    	self.resourceNode_ = ccui.loadWidget(resourceFilename)
    else
        --[[
        local obj = CustomNode.CustomRootNodeReader:create()
        obj:setEventLocator(function (funcname)
            return function (sender,evt)
                print("onEvent",sender,evt)
            end
        end)
    	self.resourceNode_ = obj:createNode("myclass",resourceFilename)]]
        self.resourceNode_ = cc.CSLoader:createNode(resourceFilename)
    end
    assert(self.resourceNode_, string.format("ViewBase:createResoueceNode() - load resouce node from file \"%s\" failed", resourceFilename))
    self:addChild(self.resourceNode_)
end

function ViewBase:createResoueceBinding(binding)
    cclog("createResoueceBinding..........")
    assert(self.resourceNode_, "ViewBase:createResoueceBinding() - not load resource node")
    for nodeName, nodeBinding in pairs(binding) do
        cclog("nodeName:"..nodeName)
        local node = self.resourceNode_:getChildByName(nodeName)
        assert(node)
        if nodeBinding.varname then
            self[nodeBinding.varname] = node
        end
        dump(nodeBinding.events)
        for _, event in ipairs(nodeBinding.events or {}) do
            if event.event == "touch" then
                --node:onTouch(handler(self, self[event.method]))
                node:addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self[event.method])})
            end
        end
    end
end

function ViewBase:showWithScene(transition, time, more)
    self:setVisible(true)
    local scene = display.newScene(self.name_)
    scene:addChild(self)
    display.runScene(scene, transition, time, more)
    return self
end

return ViewBase
