
local MainScene = class("MainScene", cc.load("mvc").ViewBase)

MainScene.RESOURCE_FILENAME = "ui2/MainView_1.csb"

function MainScene:onCreate()
    for i = 1,self:getChildrenCount() do
        local child = self:getChildren()[i]
        print("child name:"..child:getName())
    end
    local node = self:getChildren()[1]
    local panel = node:getChildByName("Panel")
    
end

return MainScene
