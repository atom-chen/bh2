
cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")
cc.FileUtils:getInstance():addSearchPath("res/ui2")

-- cclog
cclog = function(...)
    print(string.format(...))
end

-- CC_USE_DEPRECATED_API = true
require "init"

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
    return msg
end

local function main()
    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    local test = {"dfd"}
    local t = {[1] = test}

    --[[]]
    -- initialize director
    local director = cc.Director:getInstance()
    local glview = director:getOpenGLView()
    if nil == glview then
        glview = cc.GLViewImpl:createWithRect("bin", cc.rect(0,0,config.width,config.height))
        director:setOpenGLView(glview)
    end
    sharedFileUtils:addSearchPath("res/ui")

    director:setDisplayStats(config.fps)
    director:setAnimationInterval(1.0 / config.interval)

    if config.scaleByFactor then
        glview:setDesignResolutionSize(config.width,config.height, config.policy)

        if config.editor then
            display:setDesgin(config.designWidth,config.designHeight)
            display:setFactor(config.width,config.height)
        end
    else
        require("displayConfig")
        require("uber.display.autoscale")
    end


    cc.init()

     local shaders = { {v = "shaders/TPC_noMvp.vsh", f = "shaders/BanishShader.fsh", n = "BanishShader"},
    {v = "shaders/TPC_noMvp.vsh", f = "shaders/FrozenShader.fsh", n = "FrozenShader"},
    {v = "shaders/TPC_noMvp.vsh", f = "shaders/GrayScalingShader.fsh", n = "GrayScalingShader"},
    {v = "shaders/TPC_noMvp.vsh", f = "shaders/IceShader.fsh", n = "IceShader"},
    {v = "shaders/TPC_noMvp.vsh", f = "shaders/PoisonShader.fsh", n = "PoisonShader"},
    {v = "shaders/TPC_noMvp.vsh", f = "shaders/StoneShader.fsh", n = "StoneShader"},
    {v = "shaders/TPC_noMvp.vsh", f = "shaders/bright.fsh", n = "brightShader"},
    {v = "shaders/TPC_noMvp.vsh", f = "shaders/outline.fsh", n = "outline"},
    {v = "shaders/TPC_noMvp.vsh", f = "shaders/Hue.fsh", n = "hueShader"},
    --{v = "shaders/TPC_noMvp.vsh", f = "shaders/ghostlike_filterX.fsh", n = "ghostlike_filterX"},
    }
    for k,v in ipairs(shaders) do
        display.addShader(v)
    end

    --[[
    require("quick.init")
    require("utils.NotifyCenter")
    StorageMgr = require("utils.StorageMgr"):getInstance()
    StorageMgr:Load()
    local coin = StorageMgr:getHeroDataProxy():getCoin()
    cclog("--------coins:"..coin)
    --StorageMgr:getHeroDataProxy():setCoin(2840)
    local herodataproxy = require("utils.manager.HeroDataProxy"):getInstance()
    assert(herodataproxy:getCoin() == coin)
    cclog("--------coins:"..herodataproxy:getCoin())
    coin = StorageMgr:getHeroDataProxy():getCoin()
    cclog("--------after modify,coins:"..coin)

    cclog("----test motion dispatch event")
    local motionMgr = require("utils.manager.MotionMgr"):getInstance()
    motionMgr:killMonster()]]
    require("utils.NotifyCenter")
    StorageMgr = require("utils.StorageMgr"):getInstance()

    UIMgr = require("ui.UIMgr").getInstance()
    assert(UIMgr)
    require("myapp"):new():run()
end


local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end
