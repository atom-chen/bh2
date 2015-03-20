require "cocos.init"
require "uber.init"
require("Data.csv.CSVInit")
require "utils.init"
stack = require("Common.stack")
vector = require("Common.vector")
require("config")
require("lfs")
if cc.platform == "windows" then
	require('Common.fileSystem')
	require('Common.LuaXml')
end
cjson = require('cjson')

if config.editor then
	require "Editor.init"
end


--require("Data.config.configStruture")
--require("Data.config.configTable")