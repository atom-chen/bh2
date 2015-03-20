local MyApp = class("MyApp", cc.AppBase)
MyApp.__index = MyApp

require("Logic.GameLogic")
StageManager = require("Data.StageManager").new()
PlayerInfo = PlayerInfo or 
{
	id = 1,
	json = "armatures/ysn/3lianji.json",
	atlas = "armatures/ysn/3lianji.atlas",
	effectJson = "armatures/ysn_e/effect_att.json",
	effectAtlas = "armatures/ysn_e/effect_att.atlas",
}

require 'Object.ObjectManager'
ObjectManager:addInfo(PlayerInfo)
require 'Event.BaseEvent'

CharacterEditorScene = require("Editor.Character.ui.Main")

function MyApp:ctor()
	MyApp.super.ctor(self)
    
	if config.editor then
		local scene = cc.Scene:create()
		scene = CharacterEditorScene.new()
		--scene = require("Editor.ProjectCreator.ProjectCreateUI").new()
		--local layer = require("mainLayer").new()
		--scene:addChild(layer)
		cc.runScene(scene)
	else
		--[[
		StageManager:loadfromdbc()
		GameLogic:init()
		--local evt = require("Event.BeginEvent")
		--GameLogic:addEvent(evt)
		scene = cc.Scene:create()
		scene:addChild(GameLogic._map)
		cc.runScene(scene)
		--]]
		UIMgr:EnterScene(GameState.STORAGE)
	end
    --cc.runScene(scene)
end

function MyApp:onEnterBackground()
	cclog("onEnterBackground")
	--network.shutdown()
end

function MyApp:onEnterForeground()
	cclog("onEnterForeground")
	--network.reConnect()
end

return MyApp