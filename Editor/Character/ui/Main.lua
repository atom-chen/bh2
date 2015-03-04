require("Common.fileSystem")
local CharacterEditorUI = class("CharacterEditorUI",function()
 	return cc.Scene:create() 
end)
CharacterEditorUI.__index = CharacterEditorUI

function CharacterEditorUI:readFile()
	local files = fs.Browse("res/armatures/")
	self._pool = {}
	local pool = self._pool
	for k,v in pairs(files) do
	-- 惭愧,不会写lua的正则表达式...只能用最笨的方式来分解文件
		pool[k] = { mov = {} }
		local f = pool[k]
		for i=1,3 do
			local find = false
			while 1
				do

				if not f.ExJson and not f.xml and not f.json then
					find = string.find(v[i],".ExportJson") ~= nil
				end

				if find then
					f.ExJson = v[i]
					break
				end

				if not f.ExJson and not f.xml and not f.json then
			   		find = string.find(v[i],".xml") ~= nil
				end

				if find then
					f.xml = v[i]
				 	break
				end

				if not f.ExJson and not f.xml and not f.json then
			   		find = string.find(v[i],".json") ~= nil
				end

				if find then
					f.json = v[i]
					break
				end

				if not f.png then
					find = string.find(v[i],".png") ~= nil
				end

				if find then
					f.png = v[i]
				 	break
				end

				if not f.json and not f.plist and not f.atlas then
					find = string.find(v[i],".plist") ~= nil
				end

				if find then
					f.plist = v[i]
				 	break
				end

				if not f.xml and not f.atlas and not f.plist then
					find = string.find(v[i],".atlas") ~= nil
				end

				if find then
					f.atlas = v[i]
					break
				end

				break
			end

			if f.ExJson then
				break
			end
		end
	end
end

function CharacterEditorUI:ctor()
	--local t = xml.load(cc.getFullPath("res/skeleton_and_texture.xml"))
	PlatformUtility:setWindowTitle("角色编辑工具 "..display:debug())
	local layer = ccui.layer()
	self._layer = layer
	self:addChild(layer)
	
	self:readFile()

	self._tree = require("Editor.ui.TreeControl").new(uber.size(300,500),"animTree",handler(self,self.Play))
	local pool = self._pool
	for c,f in pairs(pool) do
		if f.xml then 
			local _png = "armatures/"..c.."/"..f.png
			local _plist = "armatures/"..c.."/"..f.plist
			local _xml = "armatures/"..c.."/"..f.xml
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(_png,_plist,_xml)
			local p = self._tree:addItem(c)
			self._tree:setIcon(TreeIcon.chr,p)
			_xml = cc.getFullPath(_xml);
			local skeleton = xml.load(_xml)
			f.character = skeleton:find("armatures"):find("armature").name
			local node = skeleton:find("animations")
			for k=1,#node do
				local anims = node[k]:find("animation")
				for i=1,#anims do
					local mov = anims[i]
					if not f.mov[mov.name] then
						f.mov[mov.name] = {}
						self._tree:addItem(mov.name,p)
					end
					if not f.mov[mov.name][anims.name] then
						f.mov[mov.name][anims.name] = true
					end
				end
			end
			f.frameRate = skeleton.frameRate/60
		elseif f.ExJson then
			local _json = "armatures/"..c.."/"..f.ExJson
			ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(_json)
			local p = self._tree:addItem(c)
			self._tree:setIcon(TreeIcon.chr,p)
			_json = cc.getFullPath(_json)
			local file = io.open(_json)
			if file then
				local json_str = file:read("*a")
				json_str = cjson.decode(json_str)
				f.character = json_str["armature_data"][1].name
				local anim_data = json_str["animation_data"]
				for k=1,#anim_data do
					local name = anim_data[k].name
					local mov_data = anim_data[k].mov_data
					for i=1,#mov_data do
						local mov = mov_data[i]
						if not f.mov[mov.name] then
							f.mov[mov.name] = {}
							self._tree:addItem(mov.name,p)
						end
						if not f.mov[mov.name][name] then
							f.mov[mov.name][name] = true
						end
					end
				end
				file:close()
			else
				assert(false,"没有找到目标文件")
			end
			f.frameRate = 1.0
		elseif f.json then
			local _json = "armatures/"..c.."/"..f.json
			cclog(_json)
			local p = self._tree:addItem(c)
			self._tree:setIcon(TreeIcon.chr,p)
			_json = cc.getFullPath(_json)
			local file = io.open(_json)
			if file then
				local json_str = file:read("*a")
				json_str = cjson.decode(json_str)
				f.character = c
				local anim_data = json_str["animations"]
				for k,v in pairs(anim_data) do
					local name = k
					self._tree:addItem(name,p)
					f.mov[k] = {}
					f.mov[k][c] = true
				end
				file:close()
			end
			f.frameRate = 1.0
		end
	end

	self._data = 
	{
		character = "",
		armature = nil,
		perAnim = nil,
	}

	self._anim = 
	{
		time = 0,
		running = false,
		label = nil,
	}

	self._mix = 
	{

	}

	self._tree:pos(uber.p(0,140))
	self._tree:Layout()
	layer:addChild(self._tree)
	local proLayer = self:proPanel() 
	layer:addChild(proLayer)

	self._drawNode = require 'Editor.ui.EditorNode'.new()
	layer:addChild(self._drawNode)

	sharedDirector:getScheduler():scheduleScriptFunc(handler(self,self.update),0,false)
end

function CharacterEditorUI:AnimationEnd()
	self._anim.label:setString(string.format("动画运行时间:%.2fs",self._anim.time))
	self._anim.running = false
	self._anim.time = 0
end

function CharacterEditorUI:update(dt)
	if self._data.armature then
		local rect = self._data.armature:getBoundingBox()
		self._drawNode:setOPos(cc.p(rect.x,rect.y))
		self._drawNode:setEPos(cc.p(rect.x+rect.width,rect.y+rect.height))
	end
	if self._anim.running then
		self._anim.time = self._anim.time + dt
	end
end

function CharacterEditorUI:proPanel()
	local proLayer = ccui.panel()
	proLayer:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	proLayer:setBackGroundColor(cc.c3b(150,200,250))
	proLayer:setBackGroundColorOpacity(255*0.4)
	proLayer:setSize(uber.size(300,140))

	local label = ccui.label()
	label:setString("帧率")
	label:pos(uber.p(26,116))
	proLayer:addChild(label)

	local slider = ccui.slider()
	slider:setPercent(30)
	slider:addSliderEvent(handler(self,self.onFrameRateChange))
	slider:pos(uber.p(152,116))
	proLayer:addChild(slider)

	label = ccui.label()
	label:setString("30")
	label:pos(uber.p(278,116))
	self._frameRate = label
	proLayer:addChild(label)

	local checkbox = ccui.checkBox()
	checkbox:setSelected(false)
	checkbox:pos(uber.p(26,76))
	checkbox:addCheckBoxEvent({[ccui.CheckBoxEventType.selected]=handler(self,self.onCheckBone),
		[ccui.CheckBoxEventType.unselected]=handler(self,self.onCheckBone)})
	proLayer:addChild(checkbox)

	label = ccui.label()
	label:setString("骨骼")
	label:pos(uber.p(71,76))
	proLayer:addChild(label)

	checkbox = ccui.checkBox()
	checkbox:setSelected(false)
	checkbox:pos(uber.p(119,76))
	checkbox:addCheckBoxEvent({[ccui.CheckBoxEventType.selected]=handler(self,self.onCheckSlot),
		[ccui.CheckBoxEventType.unselected]=handler(self,self.onCheckSlot)})
	proLayer:addChild(checkbox)

	label = ccui.label()
	label:setString("Slots")
	label:pos(uber.p(173,76))
	proLayer:addChild(label)

	self._loopCheck = ccui.checkBox()
	self._loopCheck:setSelected(false)
	self._loopCheck:addCheckBoxEvent({[ccui.CheckBoxEventType.selected]=handler(self,self.onCheckLoop),
		[ccui.CheckBoxEventType.unselected]=handler(self,self.onCheckLoop)})
	self._loopCheck:pos(uber.p(225,76))
	proLayer:addChild(self._loopCheck)

	label = ccui.label()
	label:setString("循环")
	label:pos(uber.p(270,76))
	proLayer:addChild(label)

	self._mixCheck = ccui.checkBox()
	self._mixCheck:setSelected(false)
	self._mixCheck:addCheckBoxEvent({[ccui.CheckBoxEventType.selected]=handler(self,self.onCheckMix),
		[ccui.CheckBoxEventType.unselected]=handler(self,self.onCheckMix)})
	self._mixCheck:pos(uber.p(26,26))
	proLayer:addChild(self._mixCheck)

	label = ccui.label()
	label:setString("混合")
	label:pos(uber.p(71,26))
	proLayer:addChild(label)


	--local btn = ccui.button({text = "sss"})
	--proLayer:addChild(btn)
	--btn:pos(uber.p(26,26))

	label = ccui.label()
	label:setString("动画运行时间:0s")
	proLayer:addChild(label)
	label:pos(uber.p(191,26))
	self._anim.label = label

	return proLayer
end

function CharacterEditorUI:onFrameRateChange(slider)
	local per = slider:getPercent()
	if per == 0 then
		per = 1
	end
	self._frameRate:setString(tostring(per))
	if self._data.armature then
		self._data.armature:setTimeScale(per/30)
	end
end

function CharacterEditorUI:onCheckBone(uiwidget)
	local selected = uiwidget:isSelected()
	if self._data.armature then
		self._data.armature:setDebugBonesEnabled(selected)
	end
end

function CharacterEditorUI:onCheckSlot(uiwidget)
	local selected = uiwidget:isSelected()
	if self._data.armature then
		self._data.armature:setDebugSlotsEnabled(selected)
	end
end

function CharacterEditorUI:onCheckLoop(uiwidget)
	self:Play()
end

function CharacterEditorUI:onCheckMix(uiwidget)
	if self._data.armature and uiwidget:isSelected() == false then
		for from,v in pairs(self._mix) do
			for to,_ in pairs(v) do
				self._data.armature:setMix(from,to,0)
			end
		end
		self._mix = {}
	end
end

function CharacterEditorUI:changeCharacter(name)
	if name ~= self._data.character then
		self._layer:removeChild(self._data.armature)
		self._data.character = name
		local info = self._pool[name]
		assert(info)
		self._data.armature = ccs.Armature:create(info.character)
		self._layer:addChild(self._data.armature)
		self._data.armature:pos(cc.CENTER)
		self._data.armature:getAnimation():setSpeedScale(info.frameRate)

		local function movementEventCallback( armature, type, movementID )
			if type == ccs.MovementEventType.loopComplete or type == ccs.MovementEventType.complete then
				if movementID ~= "standby" then
		    		armature:getAnimation():play("standby")
		    	end
		    end
		end

		self._data.armature:getAnimation():setMovementEventCallFunc(movementEventCallback)
	end
end

function CharacterEditorUI:changeCharacter_Spine(name)
	if name ~= self._data.character then
		self._layer:removeChild(self._data.armature)
		self._data.character = name
		local info = self._pool[name]
		assert(info)
		local folder = "armatures/"..info.character.."/"
		self._data.armature = sp.SkeletonAnimation:create(folder..info.json, folder .. info.atlas,1/display._scale)
		self._layer:addChild(self._data.armature)
		self._data.armature:pos(cc.CENTER)
		self._data.preAnim = nil
		self._mix = {}
	end
end

function CharacterEditorUI:Play_DGOrCCS()
	local item = self._tree:getSelectedItem()
	if item.P then
		self:changeCharacter(item.P.value)
		local info = self._pool[item.P.value]
		local bones = info.mov[item.value]
		for v,_ in pairs(bones) do
			if v ~= info.character then
				self._data.armature:getBone(v):getChildArmature():getAnimation():play(item.value)
			else
				self._data.armature:getAnimation():play(item.value)
			end
		end
	else
		self:changeCharacter(item.value)
		self._data.armature:getAnimation():playWithIndex(0)
	end

end

function CharacterEditorUI:Play_Spine()
	local item = self._tree:getSelectedItem()
	if item.P then
		self:changeCharacter_Spine(item.P.value)
		cclog("------set animation:"..item.value)
		local mix = self._mixCheck:isSelected()
		local preAnim = self._data.preAnim 
		if preAnim then
			if mix and not self._mix[preAnim] then self._mix[preAnim] = {} end
			if mix and preAnim and not self._mix[preAnim][item.value] then
				self._data.armature:setMix(preAnim,item.value,0.2)
				self._mix[preAnim][item.value] = true
			end
		end

		local loop = self._loopCheck:isSelected()
		self._data.armature:setAnimation(0,item.value, loop)
		self._data.preAnim = item.value
		self._anim.running = true
		self._data.armature:registerSpineEventHandler(handler(self,self.AnimationEnd),sp.EventType.ANIMATION_END)
	else
		self:changeCharacter_Spine(item.value)
		local info = self._pool[name]
		--self._data.armature:setAnimation(0,info. , true)
	end
end

function CharacterEditorUI:Play()
	local item = self._tree:getSelectedItem()
	local info = nil

	if not item then return end

	if item.P then
		info = self._pool[item.P.value]
	else
		info = self._pool[item.value]
	end

	if info.json then
		self:Play_Spine()
	else
		self:Play_DGOrCCS()
	end
end

return CharacterEditorUI
