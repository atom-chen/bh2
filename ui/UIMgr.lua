local UIMgr = class("UIMgr")
UIMgr.__index = UIMgr

local storageLayer = require("ui.StorageLayer")
local mainLayer = require("ui.MainLayer")

GameState = 
{
	LOGO	= 1,
	STORAGE	= 2,
	MAIN	= 3,
	BATTLE	= 4,
}

local __instance = nil
local __allowInstance = nil

function UIMgr:ctor( )
	if not __allowInstance then
		error("UIMgr is a singleton")
	end

	self:init()
end

function UIMgr:getInstance( )
	if not __instance then
		__allowInstance = true
		__instance = UIMgr.new()
		__allowInstance = false
	end

	return __instance
end

function UIMgr:init( )
	
end

function UIMgr:checkVer()
    
end

local function enterLogin()
	local sceneGame = cc.Scene:create()
    local loginLayer = require("UI.IndexLayer").new()
    sceneGame:addChild(loginLayer,0,10086)
    cc.runScene(sceneGame)
end

local function enterStorage()
	local scene = cc.Scene:create()
    --local storageLayer = require("ui.StorageLayer").new()
    local storageLayer = require("ui.StorageLayer").new()
    scene:addChild(storageLayer)
    cc.runScene(scene)
end

local function enterMain( )
	local sceneGame = cc.Scene:create()
	local mainLayer = require("UI.MainLayer").new()
	sceneGame:addChild(mainLayer,0,10086)
	sharedDirector:replaceScene(sceneGame)
end

local function enterBattle( )
	local sceneGame = cc.Scene:create()
	sceneGame:addChild(GameLogic._map,0,10086)
	sharedDirector:replaceScene(sceneGame)
end

local function entertest( ... )
	local sceneGame = cc.Scene:create()
    --local loginLayer = require("UI.testui").new()
    local loginLayer = require("UI.IndexLayer").new()
    sceneGame:addChild(loginLayer)
    cc.runScene(sceneGame)
end

function UIMgr:EnterScene(state)
	assert(state)

	if state == GameState.STORAGE then
		self.state = GameState.STORAGE

		enterStorage()
		--entertest()
	elseif state == GameState.MAIN then
		self.state = GameState.MAIN
		enterMain()
	elseif state == GameState.BATTLE then
		self.state = GameState.BATTLE
		enterBattle()
	else
		assert(false,string.format("non definded state:%d",state))
	end
end

function UIMgr:getMainLayer()
	if self.state == GameState.MAIN then
		local scene = sharedDirector:getRunningScene()
		local layer = scene:getChildByTag(10086)
		assert(layer)
		return layer
	end
end

function UIMgr:ShowInfo( context )
	local layer = sharedDirector:getRunningScene():getChildByTag(10086)
	if layer then
		local label = ccui.label({text=context,fontSize=30,color=cc.c3b(255,0,0)})
		label:pos(cc.CENTER)
		label:setScale(10)
		local scaleAction = cc.ScaleTo:create(0.08,1)
		local fadeAction = cc.FadeOut:create(2.5)
		label:runAction(cc.Sequence:create(scaleAction,fadeAction,cc.CallFunc:create(function ()
			label:removeFromParent()
		end)))
		layer:addChild(label,100000)
	end
end


return UIMgr