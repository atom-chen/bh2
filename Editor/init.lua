require("Editor.command.init")

KeyBoardManager = require("Common.KeyBoardManager").new()

brtFilter = require("Editor.filter.brightness")
hueFilter = require("Editor.filter.hue")

ccs.registerTriggerClass("brightShader",brtFilter.new)
ccs.registerTriggerClass("hueShader",hueFilter.new)

EditorConfig = require("Editor.Data.EditorConfig").new()

SceneManager = require("Editor.SceneEditor.Manager").new()
ProjectManager = require('Editor.Data.ProjectManager').new()

MSGBOX = function(...)
	local msg = require "Editor.ui.MessageBox".new()
	msg:setString(...)
	local scene = sharedDirector:getRunningScene()
	if scene then
		scene:addChild(msg)
	end
	return msg
end

sharedFileUtils:addSearchPath("res/Editor")


