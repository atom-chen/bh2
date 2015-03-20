
errorCode =
{
    OK = 0,

    --Money:
    NOT_ENOUGH_COIN = 1,

    --ITEM:
    NOT_EXIST_ITEM = 2,         --不存在此物品
    ITEM_HAS_BEEN_VERIFY = 3,   --物品已被鉴定
    ITEM_ISNOT_RANDOMLY = 4,    --物品没有随机属性
    ITEM_SHOULD_NOT_BE_FORGED = 5,  --物品不能被强化
    CANNOT_EQUIP_UNVERIFY_ITEM = 6, --物品还未被鉴定，不能装备

    --Player:
    HAS_HIRED_PLAYER = 50,    --已经雇佣过此英雄
    PLAYER_UNLOCK = 51,       --英雄未解锁
    PLAYER_ALREADY_IN_TEAM = 52,    --英雄已经在队伍中
    PLAYER_NOT_ENOUGH_LEVEL = 53,   --英雄等级不足
    PLAYER_EQUIP_NOT_ENOUGH_LEVEL = 54, --装备需求等级大于英雄等级
    PLAYER_DO_NOT_HAS_EQUIP = 55,   --英雄没有此装备   

    --Bag:
    NOT_ENOUGH_BAG_SLOTS = 100, --背包没有足够的格子
    NOT_EXIST_THIS_ITEM_IN_BAG = 101,   --背包中没有此物品

    --Achievement
    ACHIEVEMENT_NOT_DONE = 150,     --成就未完成
    ACHIEVEMENT_HAS_BEEN_SUBMITED = 151,    --成就已经被领取
}