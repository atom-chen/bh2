local StorageMgr = class("StorageMgr")
StorageMgr.__index = StorageMgr

local __instance = nil
local __allowInstance = nil

local HexData = require("utils.HexData")
local gameState = require("utils.GameState")
local storageName = ""

local teamDataMgr = require("utils.manager.TeamDataMgr")
local BagDataMgr = require("utils.manager.BagDataMgr")
local stageDataMgr = require("utils.manager.StageDataMgr")
local questDataMgr = require("utils.manager.QuestDataMgr")
local motionMgr = require("utils.manager.MotionMgr")
local Player = require("utils.Player")
local AchievementDataMgr = require("utils.manager.AchievementDataMgr")

local psw = "U1b2e8r"
local key = "the!one3"

--[[
多存档
--队伍信息：钻石，金币，复活卷轴，出战队列，未出战队列
--英雄信息：装备，等级，经验，(属性：生命值,攻击，防御。。。)，
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
    self._teamDataMgr = teamDataMgr:getInstance()
    self._teamDataMgr:setMgr(self)
    self._bagDataMgr = BagDataMgr:getInstance()
    self._bagDataMgr:setMgr(self)
    self._stageDataMgr = stageDataMgr:getInstance()
    self._stageDataMgr:setMgr(self)
    self._questDataMgr = questDataMgr:getInstance()
    self._questDataMgr:setMgr(self)
    self._motionMgr = motionMgr:getInstance()
    self._motionMgr:setMgr(self)
    self._achievementDataMgr = AchievementDataMgr:getInstance()
    self._achievementDataMgr:setMgr(self)

    self._players = {}
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
    self._teamDataMgr:Reset()
    self._bagDataMgr:Reset()
    self._stageDataMgr:Reset()
    self._questDataMgr:Reset()
    self._achievementDataMgr:Reset()
    self._players = {}
end

function StorageMgr:Create(storageIndex)
    storageName = "storage_" .. storageIndex ..".dat"
    self:InitGameState()

    --创建存档的同时，需要做的事情：
    --赠予英雄，开启关卡,赠予背包格子,添加成就链,
    cclog("创建初生英雄")
    local player = self:CreatePlayer(1)
    self._teamDataMgr:addBattleSeq(1,1)
    self._bagDataMgr:modifyTotalSlots(48)
    self._bagDataMgr:modifyOwnSlots(8)

    
    
    self._stageDataMgr:addAllowableStage(1)

    --添加1-1章节的成就
    self._achievementDataMgr:addAchievement(1)
    self._achievementDataMgr:addAchievement(2)
    self._achievementDataMgr:addAchievement(3)

    self._stageDataMgr:addAllowableStage(30)
self._teamDataMgr:modifyCoin(500)
    self:Save()
end

function StorageMgr:CreatePlayer(id)
    --要创建的player是否已经存在
    for k,player in pairs(self._players) do
        if player:getId() == id then
            cclog("-------player already exist")
            return
        end
    end

    local player = Player.new()
    player:Create(id)
    self._players[id] = player
    return player
end

function StorageMgr:addBattleSeq(player,index)
    -- body
end

function StorageMgr:getBattleSeq()
    
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
    dump(data,"Storage file content:",4)
	gameState.save(data)
end

function StorageMgr:Load(storageIndex)
    self:Reset()

    storageName = "storage_" .. storageIndex ..".dat"
    self:InitGameState()

	local filename = gameState.getGameStatePath()
	if cc.isFileExist(filename) then
		local parseTable = gameState.load()
        if not parseTable then return false end
        dump(parseTable,"storage file content:",4)
		self:Serialize(parseTable)
	else
        cclog("不存在存档"..storageIndex)
		self:Reset()
	end

    return true
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
            local str = crypto.decryptXXTEA(event.values.data, psw)
            local gameData = json.decode(str)
            dump(gameData, "gameData:")
            return gameData
        elseif "save" == event.name then
            local str = json.encode(event.values)
            if str then
                str = crypto.encryptXXTEA(str, psw)
                returnValue = {data = str}
            else
                print("ERROR, encode fail")
                return
            end

            return {data = str}
        end
    end

    gameState.init(stateListener, storageName, key)
end

function StorageMgr:getJsonData()
	local retData = {}
	
    retData["teamInfo"] = self._teamDataMgr:GetData()
    retData["bagInfo"] = self._bagDataMgr:GetData()
    retData["achievementsInfo"] = self._achievementDataMgr:GetData()
    retData["stageInfo"] = self._stageDataMgr:GetData()

    assert(#self._players > 0,"没有player的数据")
    local playerCount = 1
    for k,player in pairs(self._players) do
        retData["player"..playerCount] = player:GetData()
        playerCount = playerCount + 1
    end
    

	return retData
end

function StorageMgr:Serialize(jsonValue)
    
    cclog("----StorageMgr:Serialize")
    self._teamDataMgr:Load(jsonValue["teamInfo"])
    self._bagDataMgr:Load(jsonValue["bagInfo"])
    self._achievementDataMgr:Load(jsonValue["achievementsInfo"])
    self._stageDataMgr:Load(jsonValue["stageInfo"])
    self._questDataMgr:Load(jsonValue)
    self._motionMgr:Load(jsonValue)


    for k,v in pairs(jsonValue) do
        if string.find(k,"player") then
            local player = require("utils.Player").new()
            cclog("Load Player id:"..v.id)
            player:Load(v)
            self._players[v.id] = player
        end
    end

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
end

function StorageMgr:getTeamDataMgr()
	--assert(self._teamDataMgr,"ERROR:Invaild singleton 'HeroDataProxy'")
	return self._teamDataMgr or teamDataMgr:getInstance()
end

function StorageMgr:getStageDataMgr()
    return self._stageDataMgr
end

function StorageMgr:getQuestDataProxy()
	--assert(self._teamDataMgr,"ERROR:Invaild singleton 'HeroDataProxy'")
	return self._questDataMgr or questDataMgr:getInstance()
end

function StorageMgr:getBagDataMgr()
    return self._bagDataMgr
end

function StorageMgr:getAchievementDataMgr()
    return self._achievementDataMgr
end

function StorageMgr:getPlayer(id)
    assert(self._players[id],"Invaild player id:"..id)
    return self._players[id]
end

function StorageMgr:hasPlayer(id)
    if self._players[id] then
        return true
    end
    return false
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