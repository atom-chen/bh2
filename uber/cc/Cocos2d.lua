cc = cc or {}
cclog("required cc module")
local p = uber.PACKAGE_NAME .. ".cc"

sharedDirector = cc.Director:getInstance()
sharedFileUtils = cc.FileUtils:getInstance()

require(p..".NodeExtend")
require(p..".LayerEx")
require(p..".SceneExtend")

cc.AppBase = import(".AppDelegate")
cc.ver = "3.x"--cocos2dVersion()
if cc.ver then
    cclog("cocos2dx ver : " .. cc.ver)
end

local sharedApplication = cc.Application:getInstance()
local target = sharedApplication:getTargetPlatform()
if target == cc.PLATFORM_OS_WINDOWS then
    cc.platform = "windows"
elseif target == cc.PLATFORM_OS_MAC then
    cc.platform = "mac"
elseif target == cc.PLATFORM_OS_ANDROID then
    cc.platform = "android"
elseif target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
    cc.platform = "ios"
    if target == cc.PLATFORM_OS_IPHONE then
        cc.model = "iphone"
    else
        cc.model = "ipad"
    end
end

function cc.getFullPath(filename)
	return sharedFileUtils:fullPathForFilename(filename)
end

function cc.isFileExist(filename)
    return sharedFileUtils:isFileExist(filename)
end

function cc.init()
    winSize = sharedDirector:getWinSize()
    cc.CENTER = cc.p(winSize.width/2,winSize.height/2)
    cc.language = sharedApplication:getCurrentLanguage()
end

function cc.runScene(scene)
    if sharedDirector:getRunningScene() then
        sharedDirector:replaceScene(scene)
    else
        sharedDirector:runWithScene(scene)
    end
    return scene
end

function cc.pushScene(scene)
    if sharedDirector:getRunningScene() then
        sharedDirector:pushScene(scene)
    else
        sharedDirector:runWithScene(scene)
    end
    return scene
end

function cc.popScene()
    if sharedDirector:getRunningScene() then
        sharedDirector:popScene()
    end
end

function cc.getFileData(filename)
    local fileIO = FileIO:create()
    return fileIO:getFileData(filename)
end

function cc.openImage(jpg,mask)
    local fileIO = FileIO:create()
    return fileIO:openImage(jpg,mask)
end

CC_SAFE_RETAIN = function (ccnode)
    if ccnode ~= nil then
        ccnode:retain()
    end
end

CC_SAFE_RELEASE = function (ccnode)
    if ccnode ~= nil then
        ccnode:release()
    end
end

function cc.s2p(size)
    return cc.p(size.width,size.height)
end

cc.pZero = cc.p(0,0)
cc.sZero = cc.size(0,0)
