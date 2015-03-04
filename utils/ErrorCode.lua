
errorCode =
{
    ERROR_CHAR_CREATE_LIMIT      = 1001,  -- 角色创建数限制
    ERROR_CHAR_CREATE_INIT       = 1002,  -- 角色初始化错误
    ERROR_CHAR_CREATE_SAVEDB     = 1003,  -- 新角色保存数据库错
    ERROR_CHAR_TAG_EXIST         = 1004,  -- 昵称已经存在
    ERROR_CHAPTER_NOT_EXIST      = 1101,  -- 章节不存在
    ERROR_CHAPTER_NOT_OPEN       = 1102,  -- 章节未开启

    ERROR_DECK_OPERATION_FAIL       = 2001,  --卡牌操作失败
    ERROR_DECK_NOT_EXIST            = 2002,  --卡组不存在
    ERROR_DECK_NAME_IN_USE          = 2003,  --卡套重名
    ERROR_DECK_CARD_NOT_ENOUGH      = 2004,  --该类型卡片不够
    ERROR_DECK_CARD_FULL            = 2005,  --卡套已满
    ERROR_DECK_CARD_NOT_EXIST       = 2006,  --卡片不存在
    ERROR_DECK_CARD_CLASS_NOT_MATCH = 2007,  --职业不符
    ERROR_DECK_CARD_TOO_MUCH        = 2008,  --同类型卡片太多
    ERROR_DECK_SAVE_FAIL            = 2009,  --保存卡牌失败
    ERROR_DECK_DUST_NOT_ENOUGH      = 2010,  --卡牌合成尘不足
    ERROR_DECK_CARD_NUM             = 2011,  --卡牌数不对
    ERROR_DECK_CARD_DISENCHANT      = 2012,  --卡牌不能分解
    ERROR_DECK_DISEN_TOO_MUCH       = 2013,

    ERROR_PACK_PRODUCT_NOTEXIST    = 3001,  -- 商品不存在
    ERROR_PACK_PAY_GOLD            = 3002,  -- 卡包支付金额不对
    ERROR_PACK_GOLD_NOTENOUGH      = 3003,  -- 购买卡包金币不足
    ERROR_PACK_OPEN_NOTENOUGH      = 3004,  -- 没有卡包
    ERROR_PACK_LOOT_FAIL           = 3005,  -- 掉落失败

    ERROR_MATCH_CREATE_PLAYER      = 5001,  -- 创建player失败
    ERROR_MATCH_ALREADY_QUEUE      = 5002,  -- 已经在匹配队列中
    ERROR_MATCH_ALREADY_MATCH      = 5003,  -- 已经匹配到
    ERROR_MATCH_NOTIN_QUEUE        = 5004,  -- 不在匹配队列中
    ERROR_MATCH_NO_OPPONENT        = 5005,  -- 没找到对手
    ERROR_MATCH_PARAM_DIFFICULTY   = 5006,  -- 参数困难度非法
    ERROR_MATCH_PARAM_CLASSID      = 5007,  -- 参数职业id非法

    ERROR_ARENA_GOLD_NOTENOUGH     = 6001,  -- 金币不足
    ERROR_ARENA_CLASS_NOTINENUM    = 6002,  -- 不是列举的职业之一
    ERROR_ARENA_CARD_NOTINENUM     = 6003,  -- 不是列举的卡牌之一
    ERROR_ARENA_INVALID_WINNUM     = 6004,  -- 胜场数非法

    ERROR_BATTLE_CREATE_CARD     = 8001,  -- 创建卡牌出错
    ERROR_BATTLE_CARD_NOTFOUND   = 8002,  -- 找不到卡牌
    ERROR_BATTLE_GAME_STATUS     = 8003,  -- 游戏状态不对
    ERROR_BATTLE_UNIT_NOTEXIST   = 8004,  -- Unit不存在
    ERROR_BATTLE_TARGET_NOTEXIST = 8005,  -- 目标不存在
    ERROR_BATTLE_LOOKER_NOTREADY = 8006,  -- 对战双方未入场
    ERROR_BATTLE_LOOKER_ENTERED  = 8007,  -- 观战已经进入
    ERROR_BATTLE_LOOKER_FULL     = 8008,  -- 观战人数已满
    ERROR_BATTLE_PLAYER_ENTERED  = 8009,  -- 对战角色已经进入
    ERROR_BATTLE_PLAYER_FULL     = 8010,  -- 对战角色已满
    ERROR_BATTLE_PLAYER_FLIPED   = 8011,  -- 已经通知了掷硬币了
    ERROR_BATTLE_MAP_NOTFOUND    = 8012,  -- 对战地图未找到
    ERROR_BATTLE_PLAYER_NOTROUND = 8013,  -- 不是当前player的回合
    ERROR_BATTLE_CHANGE_TOOMUCH  = 8014,  -- 换牌过多
    ERROR_BATTLE_NOT_ROUND       = 8015,  -- 不是player当前回合
    ERROR_BATTLE_PLACE_INVALID   = 8016,  -- 位置不对
    ERROR_BATTLE_NOT_PLAYER      = 8017,  -- 不是对战双方    
    ERROR_BATTLE_CARD_CHANGED    = 8018,  -- 已经换过手牌了
    ERROR_BATTLE_HAND_FULL       = 8019,  -- 手牌已满
    ERROR_BATTLE_PLAYER_NOMANA   = 8020,  -- 法力水晶不足
    ERROR_BATTLE_CARD_POSITION   = 8021,  -- 卡牌坐标不对
    ERROR_BATTLE_PLAYER_CANNOTACT  = 8022,  -- 无法行动
    ERROR_BATTLE_PLAYER_ATTACKED   = 8023,  -- 已经攻击过了
    ERROR_BATTLE_PLAYER_ZEROATTACK = 8024,  -- 无攻击力
    ERROR_BATTLE_PLAYER_DIED       = 8025,  -- 死亡    
    ERROR_BATTLE_MINION_DIED       = 8026,  -- 已经死亡
    ERROR_BATTLE_MINION_CANTACT    = 8027,  -- 无法行动
    ERROR_BATTLE_MINION_SLEEPING   = 8028,  -- 休息中
    ERROR_BATTLE_MINION_ATTACKED   = 8029,  -- 已经攻击过了
    ERROR_BATTLE_MINION_ZEROATTACK = 8030,  -- 无攻击力  
    ERROR_BATTLE_MINION_FULL       = 8031,  -- 已满
    ERROR_BATTLE_EQUIPMENT_DESTROY  = 8032, -- 装备损坏,没耐久了
    ERROR_BATTLE_EQUIPMENT_ATTACKED = 8033, -- 已经攻击过了
    ERROR_BATTLE_ATTACK_HIDE       = 8034,  -- 隐身
    ERROR_BATTLE_ATTACK_HAVETAUNT  = 8035,  -- 有其他嘲讽怪
    ERROR_BATTLE_MINION_CANTATTACK = 8036,  -- 无法攻击
    ERROR_BATTLE_SKILL_NULL        = 8037,  -- 技能为空
    
}