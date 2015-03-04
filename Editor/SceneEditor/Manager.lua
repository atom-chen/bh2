function pArray(p)
	if not p then return nil end
	local a = {}
	if p.x ~= nil then
		a["x"] = p.x
	end
	if p.y ~= nil then
		a["y"] = p.y
	end
	if p.z ~= nil then
		a["z"] = p.z
	end
	return a
end

SceneObject = 
{
	PlistName = nil,
	plistFolder = "",
	Filename = "SceneObject.png",
	Flip 	= { x=false, y=false },
	Pos 	= { x=0, y=0 },
	zOrder  = 0,
	Rotation = 0,
	Scale   = { x=1, y=1 },
	Opacity = 255,  -- 不透明度,0-255
	Filter  = nil,  -- filter表,保存滤镜名称和参数值
	locked  = false, --  界面锁定,锁定之后不可对其做任何操作
	visible = true, -- 可视,暂时预留
	name = "Object",
}

local function getFolderName(filename)  
	----去除文件名，获取文件路径前缀
	if string.find(filename, "/") then
    	return string.match(filename, "(.+)/[^/]*%.%w+$") --*nix system 
    end

    if string.find(filename, "\\") then
    	return string.match(filename, "(.+)\\[^\\]*%.%w+$") --windows
    end

    return ""
end

local function getFileName( filename )
	--从文件的绝对路径中获取到文件名
	local dest_filename = filename

	if string.find(filename, "\\") then
		dest_filename = string.match(filename, ".+\\([^\\]*%.%w+)$")
	end

	if string.find(filename, "/") then
		dest_filename = string.match(filename, ".+/([^/]*%.%w+)$")
	end

	return dest_filename
end

function SceneObject:getJsonData()
	cclog("Manager SceneObject getJsonData")
	local data = {}
	local fn = self.Filename
	if string.find(self.Filename,"\\") then
        cclog("路径中包含斜杠")
    	if string.find(self.Filename,"%.json") then
    		--spine文件，需要把atlas,png,json拷贝到Res
    		local path = getFolderName(self.Filename)
			path = string.gsub(path,"/","\\")
			if path ~= "" and path ~= ProjectManager._project.workpath.."\\Res" then
				local files = fs.Browse(path)
		    	for k,filename in pairs(files) do
		    		local srcFile = path .. "\\" .. filename
		    		cclog("copy "..srcFile.." "..ProjectManager._project.workpath.."\\Res\\"..filename)
		    		fs.copy(srcFile,ProjectManager._project.workpath.."\\Res\\"..filename)
		    	end
		   	end
		   	fn = getFileName(self.Filename)
    	else
    		fn = string.ippath(self.Filename)
	        cclog("copy "..self.Filename.." "..ProjectManager._project.workpath.."\\Res\\"..fn)
	    	fs.copy(self.Filename,ProjectManager._project.workpath.."\\Res\\"..fn)
	    	--os.execute("copy "..self.Filename.." "..ProjectManager._project.workpath.."\\Res\\"..fn)
    	end
	end

	if self.PlistName then
		local path = getFolderName(self.PlistName)
		path = string.gsub(path,"/","\\")
		if path ~= "" and path ~= ProjectManager._project.workpath.."\\Res" then
			local files = fs.Browse(path)
	    	for k,filename in pairs(files) do
	    		local srcFile = path .. "\\" .. filename
	    		cclog("copy "..srcFile.." "..ProjectManager._project.workpath.."\\Res\\"..filename)
	    		fs.copy(srcFile,ProjectManager._project.workpath.."\\Res\\"..filename)
	    	end
		end
    	
	end
	
	data["FileName"] = fn
	
	data["Pos"] = pArray(self.Pos)
	data["Flip"] = pArray(self.Flip)
	data["zOrder"] = self.zOrder
	data["Rotation"] = self.Rotation
	data["Scale"] = pArray(self.Scale)
	data["Opacity"] = self.Opacity
	if self.Filter then
		data["Filter"] = self.Filter:getJsonData()
	end
	if self.PlistName then
		data["PlistName"] = getFileName(self.PlistName)
	end
	data["locked"] = self.locked
	data["visible"] = self.visible
	data["name"] = self.name
	return data
end

function SceneObject:serialize(jsonValue)
	self.Filename = jsonValue["FileName"]
	self.Pos = jsonValue["Pos"]
	self.Flip = jsonValue["Flip"]
	self.zOrder = jsonValue["zOrder"]
	self.Rotation = jsonValue["Rotation"]
	self.Scale = jsonValue["Scale"]
	self.Opacity = jsonValue["Opacity"]
	self.locked = jsonValue["locked"]
	self.visible = jsonValue["visible"]
	self.name = jsonValue["name"]
	self.PlistName = jsonValue["PlistName"]
	local filter = jsonValue["Filter"]
	if filter then
		self.Filter = ccs.ObjectFactory.getInstance():createObject(filter["name"])
		self.Filter:serialize(filter)
	end
end


GroundLayer = import(".GroundLayer")
Ground = import(".Ground")
FrontGround = import(".FrontGround")
Floor = import(".Floor")
GameScene = import(".GameScene")

local SceneManager = class("SceneManager")
SceneManager.__index = SceneManager

function SceneManager:ctor()
	self._Scenes = {}
end

function SceneManager:addScene(name,width)
	if name and width then
		--assert(self._Scenes[name] == nil)
		for k,v in pairs(self._Scenes) do 
            cclog(" scene name k:"..k)
		end
		cclog("------------创建scene")
		self._Scenes[name] = GameScene.new(name,width)
		return self._Scenes[name]
	elseif type(name) == "table" then
		local scene = name
		self._Scenes[scene._name] = scene
		return scene
	end
	return nil
end

function SceneManager:removeScene(param)
	if type(param) == "string" then
		if self._Scenes[param] then
			self._Scenes[param] = nil
		end
	elseif type(param) == "table" then
		self._Scenes[param._name] = nil
	end
end

function SceneManager:findScene(name)
	for k,v in pairs(self._Scenes) do
         cclog(" self._Scenes k:"..k)
	end
	return self._Scenes[name]
end

function SceneManager:renameScene(old_name,new_name)
	local scene = self._Scenes[old_name]
	if scene then
		scene._name = new_name
		self._Scenes[old_name] = nil
		self._Scenes[new_name] = scene
	end
end

function SceneManager:Save(path,name,ext)
	--cclog("----SceneManager:Save  self:findScene(name):"..self:findScene(name)._name)
	cclog("--------- save scene ---------")
	local scenedata = self:findScene(name):getJsonData()
	local json_str = json.encode(scenedata)

	local fileName = path.."/Scenes/"..name..ext
	local file = io.open(fileName,"w+")
	if file then
		file:write(json_str) 
		file:close()
	end
end

function SceneManager:Load(filePath)
	local file = io.open(filePath)
	if file then
		local json_str = file:read("*a")
		local parseTable = cjson.decode(json_str)
		local widthtemp = parseTable["width"]
		local scene = self:addScene("newScene",widthtemp)
		scene:serialize(parseTable)
		file:close()
		return scene
	end
	return nil
end

function SceneManager:prevLoad(filePath)
	local file = io.open(filePath)
	if file then
		local json_str = file:read("*a")
		local parseTable = cjson.decode(json_str)
		local widthtemp = parseTable["width"]
		local scene = self:addScene("newScene_preview",widthtemp)
		scene:serialize(parseTable)
		file:close()
		return scene
	end
	return nil
end

return SceneManager