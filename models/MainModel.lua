
local MainModel = class("MainModel")

MainModel.__index = MainModel

function MainModel:ctor()
	self._heroData = require("utils.StorageMgr"):getInstance():getHeroDataProxy()
end

function MainModel:comsumeDiamodToAddCoin()
	--消耗钻石增加金币
	local costDiamond,addCoin = 2,200
	local opRet = 0
	if self._heroData:getDiamond() < costDiamond then
		opCode = "Not_Enough_Diamond"
	end

	--一系列校验
	if opRet == 0 then
		self._heroData:modifyDiamond(costDiamond)
		self._heroData:modifyCoin(addCoin)
	end

	return opRet
end

function MainModel:backToStorage( ... )
	StorageMgr:Save()
end

return MainModel