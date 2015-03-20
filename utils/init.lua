require("utils.functions")
require("utils.debug")
require("utils.ErrorCode")
MotionEvents = {
	KILL_MONSTER = "KILL_MONSTER",
    PLAYER_DEAD_EVENT = "PLAYER_DEAD_EVENT",
}

StageType = 
{
    Normal = 1,
    Challenge = 2,
}

Events = 
{
	MONEY_CHANGE = "MONEY_CHANGE",
	EQUIP_CHANGE = "EQUIP_CHANGE",
    PLAYER_PROPS_CHANGE = "PLAYER_PROPS_CHANGE",
    
	DIAMOND_CHANGE = "DIAMOND_CHANGE",
	KILL_MONSTER = "KILL_MONSTER",

    UPGRADE_SPELL = "UPGRADE_SPELL",
    FORGE_EQUIP = "FORGE_EQUIP",
}

GET_TREATURE_VALUE = 100

ItemProps = 
{
    hp = 1, 
    attack = 2,
    defence = 3,
    magic_defence = 4,
    single_magicdefence = 5,
    crit = 6,  --pct
    hit = 7,   --pct
    critdmg = 8, --pct
    addSpellLevel = 9,
    addClassSpellLevel = 10,
    addAllSpellLevel = 11,
    addTreatureLoot = 12,  ---pct
    kb = 13,  ----pct
    defenceKb = 14,  --pct
    kd = 15,    --pct
    defenceKd = 16,     --pct
    addDmgTokd = 17,    --pct
    addDmgToClass = 18, --pct
    addDefenceToClass= 19,  --pct
    strikeDefence = 20, 
    strikeDefencePct = 21, --pct
}

Quality = 
{
	S = 1,
	A = 2,
	B = 3,
	C = 4,
	D = 5,
	E = 6
}

CostType = 
{
    COIN = 1,
    RMB = 2,
}

LootMgr = require("utils.manager.LootMgr"):getInstance()

function LoadLootTable()
    local dbcStore = {}
	local filename = cc.getFullPath("csv/loot_word_template.csv")
	if cc.isFileExist(filename) == false then
         cclog("required csv : "..filename.." not found")
         return nil
    end
    cclog("load csv "..filename)

    local data2 = sharedFileUtils:getStringFromFile(filename) --cc.HelperFunc:getFileData(filename)
    --print(data2)
    assert(data2 ~= "", filename .. "无法读取内容。尝试用nodepad++把文件转换为UTF无BOM编码")
    local data = string.split(data2,"\n")

    for i = 1,#data do
        while true do
            if i == 1 then break end
            local lineStr = string.trim(data[i])
            local tmp = string.split(lineStr, ",")
            if #tmp < 1 then break end
            local id = tonumber(tmp[1])
            if not id then break end
            local word_id = tonumber(tmp[2])
            local chance = tonumber(tmp[3])
            local groudId = tonumber(tmp[4])
            local LootStoreWord = {id = id,word_id = word_id,chance = chance,groudId = groudId}
            LootMgr:addEntry(LootStoreWord)
            break
        end
    end
end

LoadLootTable()

function getSpellIcon(spellId)
    local entry = sSpellEntry[spellId]
    if entry then
        if sSpellIconStore[entry.displayID] then
            return sSpellIconStore[entry.displayID].icon
        end
    end

    return "ui/hsk_0.png"
end

function getSpellName(spellId)
    assert(spellId)
    return sSpellLocaleStore[spellId].name[0]
end

function getSpellDesc(spellId)
    assert(spellId)
    return sSpellLocaleStore[spellId].desc[0]
end

SpellNode = 
{
    firstId = 0,
    prevId = 0,
    nextId = 0,
    rankId = 0,
    state = "unk",
}

gSpellChain = {}
gFirstSpellChain = {}

function initSpellChain()
    for k,v in pairs(sSpellChainStore) do
        local entry = v
        if entry then
            local node = gSpellChain[entry.id]
            if not node then
                gSpellChain[entry.id] = clone(SpellNode)
                node = gSpellChain[entry.id]
            end
            node.firstId = entry.firstId
            node.prevId = entry.prevId
            node.rank = entry.rank
            node.costType = entry.costType
            node.cost = entry.cost
            node.reqLv = entry.req_level

            if not gFirstSpellChain[entry.firstId] then
                gFirstSpellChain[entry.firstId] = {}
            end
            if gFirstSpellChain[entry.firstId][entry.rank] then
                cclog(string.format("LoadItemIntensify, item id %d rank(%d) repeat!",entry.firstId, entry.rank ))
                assert(false)
            end
            gFirstSpellChain[entry.firstId][entry.rank] = entry.id
        end
    end
end
cclog("----------------")
uber.TimingBegin()
initSpellChain()
uber.TimingEnd()

gChapterChain = {}
gFirstChapterChain = {}
ChapterNode = 
{
    firstId = 0,
    prevId = 0,
    nextId = 0,
    rankId = 0,
    state = "unk",
}

local function InitChapter()
    for k,v in pairs(sChapterStore) do
        local entry = v
        if entry then
            local node = gChapterChain[entry.id]
            if not node then
                gChapterChain[entry.id] = clone(ChapterNode)
                node = gChapterChain[entry.id]
            end
            node.firstId = entry.firstId
            node.rank = entry.number
            node.stage = entry.stage_index
            node.reqLv = entry.req_level
            node.enemyPower = entry.enemyPower
            node.reqStageId = entry.reqStageId
            node.reqStageStar = entry.reqStageStar
            node.achievements = entry.achievements

            if not gFirstChapterChain[entry.firstId] then
                gFirstChapterChain[entry.firstId] = {}
            end
            if gFirstChapterChain[entry.firstId][entry.number] then
                cclog(string.format("LoadChapter, item id %d rank(%d) repeat!",entry.firstId, entry.rank ))
                assert(false)
            end
            gFirstChapterChain[entry.firstId][entry.number] = entry.id
        end
    end
end

InitChapter()

gAchievementChain = {}
gFirstAchievementChain = {}

local function InitAchievement()
    for k,v in pairs(sAchievementStore) do
        local entry = v
        if entry then
            local node = gAchievementChain[entry.id]
            if not node then
                gAchievementChain[entry.id] = {}
                node = gAchievementChain[entry.id]
            end
            node.firstId = entry.firstId
            node.rank = entry.rank
            node.type = entry.type
            node.subType = entry.subType
            node.chapterId = entry.chapterId
            node.reqCount = entry.reqCount

            if not gFirstAchievementChain[entry.firstId] then
                gFirstAchievementChain[entry.firstId] = {}
            end
            if gFirstAchievementChain[entry.firstId][entry.rank] then
                cclog(string.format("LoadChapter, item id %d rank(%d) repeat!",entry.firstId, entry.rank ))
                assert(false)
            end
            gFirstAchievementChain[entry.firstId][entry.rank] = entry.id
        end
    end
end

InitAchievement()

ItemLootMgr = require 'utils.manager.ItemLootMgr'.new()
ItemLootMgr:init()
local loot = ItemLootMgr:Loot(1)
local loot2 = ItemLootMgr:Loot(2)
local loot3 = ItemLootMgr:Loot(3)
local loot4 = ItemLootMgr:Loot(4)

--[[load info]]

--sObjectMgr.LoadPlayerInfo();
--sObjectMgr.LoadItemIntensify()
--LoadSpellChains()
--sObjectMgr.LoadLootTables();
--sObjectMgr.LoadSceneTemplate()