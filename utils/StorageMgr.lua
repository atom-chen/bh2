local StorageMgr = class("StorageMgr")
StorageMgr.__index = StorageMgr

local __instance = nil
local __allowInstance = nil

local HexData = require("utils.HexData")
local gameState = require("utils.GameState")
local storageName = ""
local heroDataProxy = require("utils.manager.HeroDataProxy")
local stageDataMgr = require("utils.manager.StageDataMgr")
local questDataProxy = require("utils.manager.QuestDataProxy")
local motionMgr = require("utils.manager.MotionMgr")

--[[
多存档
--通用信息：
--英雄信息：钻石，金币，复活卷轴，装备，等级，经验，(属性：生命值,攻击，防御。。。)，
            已学技能

            英雄可能要满足某种条件(升级或者进化)才能学习新的技能LearnSpell()。
            如果是通过升级学新技能，LearnSpell()中获取满足等级条件的Spell，然后学习它
            
--背包信息：背包总格子，已开启的格子数，拥有的物品({物品1，数量}，{物品2，数量})
--每日任务信息：{[1] = {id,status,reqCount,curCount}}
--成就信息：一条成就就是一条链，完成了当前成就就会出现下一条成就
--关卡信息：（关卡类型，开通的关卡StageId，通过的ChapterId,SectionId）
--佣兵信息：
--签到：（不联网的话获取不了正确的时间，无法反作弊。）
    方案1:记录最后领取奖励的日期a，若登陆的日期是a的后N天，则可以领取
    --但如果玩家第一次打开游戏的时候设置一个很前的时间，然后每次往后调整一天，就可以领取一次奖励了
    方案2：有联网就可以签到，不联网就不能签到
--商店：出售的物品
]]

function StorageMgr:ctor()
	if not __allowInstance then
		error("StorageMgr is a singleton")
	end

	self:Init()
end

function StorageMgr:getInstance( )
	if not __instance then
		__allowInstance = true
		__instance = StorageMgr.new()
		__allowInstance = false
	end

	return __instance
end

function StorageMgr:Init()
    self._heroDataProxy = heroDataProxy:getInstance()
    self._heroDataProxy:setMgr(self)
    self._stageDataMgr = stageDataMgr:getInstance()
    self._stageDataMgr:setMgr(self)
    self._questDataProxy = questDataProxy:getInstance()
    self._questDataProxy:setMgr(self)
    self._motionMgr = motionMgr:getInstance()
    self._motionMgr:setMgr(self)
end

function StorageMgr:isStorageExist(index)
    local filepath = gameState.getGameStateDir() .. "storage_"..index..".dat"
    local ret = false
    if cc.isFileExist(filepath) then
        ret = true
    end
    return ret
end

function StorageMgr:Reset()

end

function StorageMgr:Create(storageIndex)
    storageName = "storage_" .. storageIndex ..".dat"
    self:InitGameState()
    self:Save()
end

function StorageMgr:Delete(storageIndex)
    storageName = "storage_" .. storageIndex ..".dat"
    local filepath = gameState.getGameStateDir() .. storageName
    cclog("将删除存档："..filepath)
    if cc.isFileExist(filepath) then
        sharedFileUtils:removeFile(filepath)
        cclog("删除存档"..storageIndex.."成功")
    else
        assert(false)
    end
end

function StorageMgr:Save()
	local data = self:getJsonData()
	assert(data,"nil data")
	gameState.save(data)
end

function StorageMgr:Load(storageIndex)
    storageName = "storage_" .. storageIndex ..".dat"
    self:InitGameState()

	local filename = gameState.getGameStatePath()
	if cc.isFileExist(filename) then
		local parseTable = gameState.load()
		self:Serialize(parseTable)
	else
        cclog("不存在存档"..storageIndex)
		self:Reset()
	end
end

function StorageMgr:InitGameState()
    local stateListener = function(event)
        local returnValue = nil
        if event.errorCode then
            print("ERROR, load:" .. event.errorCode)
            return
        end
        local crypto = require("utils.crypto")
        if "load" == event.name then
            local str = crypto.decryptXXTEA(event.values.data, "U1b2e8r")
            returnValue = json.decode(str)
            dump(returnValue, "gameData:")
        elseif "save" == event.name then
            local str = json.encode(event.values)
            if str then
                str = crypto.encryptXXTEA(str, "U1b2e8r")
                returnValue = {data = str}
            else
                print("ERROR, encode fail")
                return
            end
        end

        return returnValue
    end

    gameState.init(stateListener, storageName, "keyHTL")
end

function StorageMgr:getJsonData()
	local retData = {}

	retData["name"] = self._heroDataProxy:getName()
	retData["coin"] = self._heroDataProxy:getCoin()
	retData["diamond"] = self._heroDataProxy:getDiamond()
	retData["level"] = self._heroDataProxy:getLevel()
	retData["exp"]	= self._heroDataProxy:getExp()
    retData["questinfo"] = self._questDataProxy:GetAllQuests()

	return retData
end

function StorageMgr:Serialize(jsonValue)
    cclog("----StorageMgr:Serialize")
    self._heroDataProxy:Load(jsonValue)
    self._stageDataMgr:Load(jsonValue)
    self._questDataProxy:Load(jsonValue)
    self._motionMgr:Load(jsonValue)

    --通用信息：钻石，金币，复活卷轴
    --英雄信息：装备，等级，经验，(属性：生命值,攻击，防御。。。)，已学技能，未学技能
    --背包信息：背包总格子，已开启的格子数，拥有的物品({物品1，数量}，{物品2，数量})
    --任务信息：
    --成就信息：
    --关卡信息：（关卡类型，开通的关卡StageId，通过的ChapterId,SectionId）
    --佣兵信息：
    --签到：
    --商店：出售的物品

    --主要功能：新手引导，人物升级，装备强化，穿卸装备，技能开启，技能升级，阵型调整，开启关卡，关卡掉落，
    --完成任务，完成成就，出售物品，购买商品
    dump(jsonValue,"jsonValue:")
end

function StorageMgr:getHeroDataProxy()
	--assert(self._heroDataProxy,"ERROR:Invaild singleton 'HeroDataProxy'")
	return self._heroDataProxy or heroDataProxy:getInstance()
end

function StorageMgr:getStageDataProxy()
    return nil
end

function StorageMgr:getQuestDataProxy()
	--assert(self._heroDataProxy,"ERROR:Invaild singleton 'HeroDataProxy'")
	return self._questDataProxy or questDataProxy:getInstance()
end


--关卡类型：过关，竞技场，Boss，防守

function StorageMgr:getMaxAllowedStageId(type_)
	-- body
end

function StorageMgr:setMaxAllowedStageId(type_)
	-- body
end

function StorageMgr:getMaxAllowedChapterId()
	-- body
end

function StorageMgr:setMaxAllowedChapterId()
	-- body
end

function StorageMgr:getMaxAllowedSectionId()
	-- body
end

function StorageMgr:setMaxAllowedSectionId()
	-- body
end

return StorageMgr