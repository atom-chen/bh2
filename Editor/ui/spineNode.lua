local spineNode = class("spineNode",function()
		if config.editor then
			return ccui.image({image="Editor/P.jpg"})
		else
			return ccui.image({image=""})
		end
	end)
spineNode.__index = spineNode

function spineNode:ctor(fullpath)
    local folder = fs.getFolderName(fullpath)
	local filename = string.gsub(fs.getFileName(fullpath),"(%.%w+)$","")
	local spinenode = sp.SkeletonAnimation:create(folder.."/"..filename..".json", folder.."/"..filename..".atlas",1/display._scale)
	spinenode:pos(cc.pMul(cc.s2p(self:getVirtualRendererSize()),0.5))
	self:addProtectedChild(spinenode,-1)

	fullpath = cc.getFullPath(fullpath)
	local anims = {}
	local file = io.open(fullpath)
	if file then
		local json_str = file:read("*a")
		json_str = cjson.decode(json_str)
		local anim_data = json_str["animations"]
		for anim_name,v in pairs(anim_data) do
			anims[#anims + 1] = anim_name
		end
	end
	spinenode:setAnimation(0,anims[1], true)
end

return spineNode