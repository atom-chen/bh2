local ViewBase = require("ui.ViewBase")
local StorageLayer = class("StorageLayer", ViewBase)

StorageLayer.RESOURCE_FILENAME = "ui/Storage.csb"
StorageLayer.RESOURCE_BINDING = { btn_ksy = {events = {[1] = {event = "touch",method = "beginGame" }} }}
StorageLayer.AUTOSCALE = true

StorageMgr = require("utils.StorageMgr"):getInstance()

function StorageLayer:onCreate()
	self:addNodesEventListener()
end

function StorageLayer:addNodesEventListener()
	local node = self:getChildren()[1]
	--self:getResourceNode():getChild("btn_ksy"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.beginGame)})

	self:getResourceNode():getChild("btn_new1"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.newStorage)})
	self:getResourceNode():getChild("btn_new1"):setTag(1)
	self:getResourceNode():getChild("btn_new2"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.newStorage)})
	self:getResourceNode():getChild("btn_new2"):setTag(2)
	self:getResourceNode():getChild("btn_cundang1"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.chooseStorage)})
	self:getResourceNode():getChild("btn_cundang1"):setTag(1)
	self:getResourceNode():getChild("btn_cundang2"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.chooseStorage)})
	self:getResourceNode():getChild("btn_cundang2"):setTag(2)
	self:getResourceNode():getChild("btn_cundang1"):getChild("btn_qingchu1"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.deleteStorage)})
	self:getResourceNode():getChild("btn_cundang1"):getChild("btn_qingchu1"):setTag(1)
	self:getResourceNode():getChild("btn_cundang2"):getChild("btn_qingchu2"):addTouchEvent({[ccui.TouchEventType.ended] = handler(self,self.deleteStorage)})
	self:getResourceNode():getChild("btn_cundang2"):getChild("btn_qingchu2"):setTag(2)
end

function StorageLayer:beginGame(node)
	node:setVisible(false)

	self:UpdateStorageView()
    
	local action = cc.CSLoader:createTimeline("ui/Storage.csb")
    action:gotoFrameAndPlay(0,false)
    self:runAction(action)
end

function StorageLayer:UpdateStorageView()
	if StorageMgr:isStorageExist(1) then
    	cclog("存档1存在")
    	self:getResourceNode():getChild("btn_cundang1"):setVisible(true)
    else
    	self:getResourceNode():getChild("btn_cundang1"):setVisible(false)
    	self:getResourceNode():getChild("btn_new1"):setVisible(true)
    	self:getResourceNode():getChild("btn_new1"):setTouchEnabled(true)
    	self:getResourceNode():getChild("btn_cundang1"):setTouchEnabled(false)
    end
    if StorageMgr:isStorageExist(2) then
    	cclog("存档2存在")
    	self:getResourceNode():getChild("btn_cundang2"):setVisible(true)
    else
    	self:getResourceNode():getChild("btn_cundang2"):setVisible(false)
    	self:getResourceNode():getChild("btn_new2"):setVisible(true)
    	self:getResourceNode():getChild("btn_new2"):setTouchEnabled(true)
    	self:getResourceNode():getChild("btn_cundang2"):setTouchEnabled(false)
    end
end

function StorageLayer:newStorage(node)
	local storageIndex = node:getTag()
	if not node:isVisible() then return end
	cclog("创建存档"..storageIndex)
	StorageMgr:Create(storageIndex)

	UIMgr:EnterScene(GameState.MAIN)
end

function StorageLayer:chooseStorage(node)
	if not node:isVisible() then return end
	cclog("进入存档"..node:getTag())
	

	local storageIndex = node:getTag()
	
    if StorageMgr:Load(storageIndex) then
    	cclog("进入主界面")
    	UIMgr:EnterScene(GameState.MAIN)
    else
    	assert(false)
    end
end

function StorageLayer:deleteStorage(node)
	if not node:isVisible() then return end
	local storageIndex = node:getTag()
	cclog("删除存档"..storageIndex)
	StorageMgr:Delete(storageIndex)

	--更新视图
	--self:UpdateStorageView()
	self:getResourceNode():getChild("btn_cundang"..storageIndex):setVisible(false)
	self:getResourceNode():getChild("btn_cundang"..storageIndex):setTouchEnabled(false)
	self:getResourceNode():getChild("btn_new"..storageIndex):setVisible(true)
	self:getResourceNode():getChild("btn_new"..storageIndex):setTouchEnabled(true)
	
end

return StorageLayer