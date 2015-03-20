require("uber.dbc.DBCStores")

AchievementEntry = 
{
	filename = "csv/achievement.csv",
	fmt 	 = "nsssiiiiiiiiiiii",
	[1]  = "id",
	[2]  = "name",
	[3]	 = "desc",
	[4]  = "rewardDesc",
	[5]	 = "firstId",
	[6]  = "rank",
	[7]	 = "type",
	[8]  = "subType",
	[9]  = "reqCount",
	[10]  = "chapterId",
	[11]  = "rewardCoin",
	[12]  = "rewardExp",
	[13] = Array("rewardItem",4,"")
}

CreatureInfoEntry = 
{
	filename = "csv/creature.csv",
	fmt 	 = "nssiiiiiiiiiiiiiiiiiiiiiiiiiiii",
	[1]  = "id",
	[2]  = "name",
	[3]	 = "desc",
	[4]  = "display",
	[5]	 = "hp",
	[6]  = "mp",
	[7]	 = "atk",
	[8]	 = "defence",
	[9]	 = "resist",
	[10] = "speedX",
	[11] = "speedY",
	[12] = "kdValue",
	[13] = "kbValue",
	[14] = "resistKd",
	[15] = "resistKb",
	[16] = "recoverKd",
	[17] = "recoverKb",
	[18] = "downSpeedX",
	[19] = "downSpeedY",
	[20] = "fallSpeedX",
	[21] = "fallSpeedY",
	[22] = "downTime",
	[23] = "starLevel",
	[24] = Array("attack",3,""),
	[25] = Array("skill",4,""),
	[26] = "loot_id",				-- 掉落id
}

LootTemplateEntry = 
{
	filename = "csv/loot_item_template.csv",
	fmt = "iiii",
	[1] = "id",
	[2] = "groupId",
	[3] = "item_id",
	[4] = "chance",
}

LocalePlayerEntry = 
{
	filename = "csv/locales_player.csv",
	fmt 	 = "nssssssssssssssssss",
	[1]  = "id",
	[2]  = Array("name",9,""),
	[3]  = Array("desc",9,""),
}

PlayerDisplayEntry = 
{
	filename = "csv/player_display.csv",
	fmt 	 = "nss",
	[1]  = "id",
	[2]  = "head_icon",
	[3]	 = "body",
}

PlayerCreateInfoEntry = 
{
	filename = "csv/playercreateinfo.csv",
	fmt 	 = "nssiiiiiiiiiiiiiiiiiiiiiiiiiii",
	[1]  = "id",
	[2]  = "name",
	[3]	 = "desc",
	[4]  = "display",
	[5]	 = "hp",
	[6]  = "mp",
	[7]	 = "atk",
	[8]	 = "defence",
	[9]	 = "resist",
	[10] = "speedX",
	[11] = "speedY",
	[12] = "kdValue",
	[13] = "kbValue",
	[14] = "resistKd",
	[15] = "resistKb",
	[16] = "recoverKd",
	[17] = "recoverKb",
	[18] = "downSpeedX",
	[19] = "downSpeedY",
	[20] = "fallSpeedX",
	[21] = "fallSpeedY",
	[22] = "downTime",
	[23] = "starLevel",
	[24] = Array("attack",3,""),
	[25] = Array("skill",4,""),
}

ItemTemplateEntry = 
{
	filename = "csv/item_template.csv",
	fmt 	 = "nssiiiiiiiiisiiiiiiiiiiiiiiiiiiiiii",
	[1]  = "id",
	[2]  = "name",
	[3]	 = "desc",
	[4]  = "category",
	[5]	 = "equip_slot",
	[6]  = "level",
	[7]	 = "reqLv",
	[8]	 = "reqClass",
	[9]	 = "attack",
	[10] = "defence",
	[11] = "hp",
	[12] = "quality",
	[13] = "icon",
	[14] = "sellprice",
	[15] = "statsCount",
	[16] = Array("stat",8,""),
	[17] = Array("statValue",8,""),
	[18] = "max_forge",
	[19] = "bRandomly",
	[20] = "loot_id",
	[21] = "displayId",
}

ItemVerifyEntry = 
{
	filename = "csv/item_verify_price.csv",
	fmt 	 = "niiiiii",
	[1]  = "level",
	[2]  = "S",
	[3]	 = "A",
	[4]  = "B",
	[5]	 = "C",
	[6]  = "D",
	[7]  = "E",
}

ItemRandomWordEntry = 
{
	filename = "csv/Item_random_word.csv",
	fmt 	 = "niiiiis",
	[1]  = "id",
	[2]  = "word_name",
	[3]	 = "word_value",
	[4]  = "forge_price",
	[5]	 = "rank",
	[6]  = "next_id",
	[7]  = "desc",
}

LootQualityEntry = 
{
	filename = "csv/loot_quality.csv",
	fmt 	 = "niiiiii",
	[1]  = "level",
	--[[[2]  = "S",
	[3]	 = "A",
	[4]  = "B",
	[5]	 = "C",
	[6]  = "D",
	[7]  = "E",]]
	[2] = Array("quality",6,"")
}

LootWordEntry = 
{
	filename = "csv/loot_word_template.csv",
	fmt 	 = "niii",
	[1]  = "id",
	[2]  = "word_id",
	[3]	 = "chance",
	[4]  = "group_id",
}

HireCostEntry = 
{
	filename = "csv/hire_cost.csv",
	fmt 	 = "ni",
	[1]  = "id",
	[2]	 = "cost",
}

LevelExpEntry = 
{
	filename = "csv/player_level_xp.csv",
	fmt 	 = "ni",
	[1]  = "level",
	[2]	 = "exp",
}

DisplayEntry = 
{
	filename = "csv/display.csv",
	fmt 	 = "nsssssii",
	[1]  = "id",
	[2]	 = "json",
	[3]  = "atlas",
	[4]  = "effectJson",
	[5]  = "effectAtlas",
	[6]	 = "head",
	[7]	 = "sizeW",
	[8]  = "sizeH",
}

PhysicsInfo = 
{
	filename = "csv/physicsinfo.csv",
	fmt 	 = "niiii",
	[1]  = "id",
	[2]	 = "ax",
	[3]  = "ay",
	[4]  = "vx",
	[5]  = "vy",
}

miscValue = 
{
	stickRaduis = 1,
	playerMoveX = 2,
	playerMoveY = 3,
	clickMeeleBtnTime = 4,--普攻按钮按下在极短时间内抬起释放普攻
	comboTime = 5, --普攻连击触发的时间
	slideDis = 6, --同时按方向键和攻击键时攻击滑行的距离
	timeCastSpell3 = 7,--普攻按下持续秒数会触发技能3
}

MiscValueInfo = 
{
	filename = "csv/miscvalue.csv",
	fmt 	 = "nsi",
	[1]  = "id",
	[2]	 = "desc",
	[3]  = "value",
}

SpellIconEntry = 
{
	filename = "csv/spell_icon.csv",
	fmt 	 = "ns",
	[1]  = "id",
	[2]  = "icon",
}

SpellChainEntry =
{
	filename = "csv/spell_chain.csv",
	fmt 	 = "niiiiiiii",
	[1]  = "id",
	[2]  = "prevId",
	[3]  = "firstId",
	[4]  = "rank",
	[5]  = "req_spell",
	[6]  = "class_mask",
	[7]  = "req_level",
	[8]	 = "costType",
	[9]	 = "cost"
}

LocaleSpellEntry = 
{
	filename = "csv/locales_spell.csv",
	fmt 	 = "nssssssssssssssssss",
	[1]  = "id",
	[2]  = Array("name",9,""),
	[3]  = Array("desc",9,""),
}

SpellEntry = 
{
	filename = "csv/spell.csv",
	fmt 	 = "niiiiiiiiiiiiissi",
	[1]  = "id",
	[2]  = "class",
	[3]  = "groupId",
	[4]  = "displayID",
	[5]  = "level",
	[6]  = "costtype",
	[7]  = "cost",
	[8]	 = "casttime",
	[9]	 = "range",
	[10] = "interrpt",
	[11] = "cooldown",
	[12] = Array("effect",3,0),
	[13] = "name",
	[14] = "desc",
	[15] = "collZ",
}

local Aura = 
{
	[1] = "aura",
	[2] = "interrpt",
	[3] = "duration",
	[4] = "mod",
	[5] = "base",
	[6] = "pct",
	[7] = "race",
	[8] = "va",
	[9] = "vb",
	[10] = "period",
	[11] = "amplitude",
	[12] = "stackcount",
	[13] = "radiusX",
	[14] = "radiusY",
	[15] = "collx",
	[16] = "colly",
	[17] = "collw",
	[18] = "collh",
	[19] = "collz",
	[20] = "hitback",
	[21] = "hitdown",
	[22] = "vx",
	[23] = "vy",
	[24] = "ax",
	[25] = "ay",
	[26] = "trigmod",
	[27] = "trigstate",
	[28] = "trigchance",
	[29] = "trigspell",
	[30] = "school",
}

SpellEffects = 
{
	filename = "csv/spell_effects.csv",
	fmt 	 = "niiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii",
	[1]  = "id",
	[2]	 = "effect",
	[3]  = "actionTag",
	[4]  = "valueMod",
	[5]  = "value_base",
	[6]  = "value_pct",
	[7]  = "value_a",
	[8]  = "value_b",
	[9]	 = "radiusX",
	[10] = "radiusY",
	[11] = "collx",
	[12] = "colly",
	[13] = "collw",
	[14] = "collh",
	[15] = "collz",
	[16] = "hitback",
	[17] = "hitdown",
	[18] = "vx",
	[19] = "vy",
	[20] = "ax",
	[21] = "ay",
	[22] = "damageType",
	[23] = Array("aura",1,Aura),
	[24] = "target",
	[25] = "targetType",
}															


SpellMoves = 
{
	filename = "csv/spell_moves.csv",
	fmt 	 = "nisiiiiiiiiiiiiiiiiii",
	[1]  = "id",
	[2]  = "spell_index",
	[3]  = "name",
	[4]  = "coll_data",
	[5]  = "collX",
	[6]  = "collY",
	[7]  = "collW",
	[8]	 = "collH",
	[9]	 = "collZ",
	[10] = "hitBack",
	[11] = "hitDown",
	[12] = "dis_movehit",
	[13] = "Hit_mod",
	[14] = "fVX",
	[15] = "fVY",
	[16] = "aX",
	[17] = "aY",
	[18] = "canHitFly",
	[19] = "canhitGround",
	[20] = "effect",
	[21] = "value",
}

SpellDisplayEntry = 
{
	filename = "csv/spelldisplay.csv",
	fmt = "niiiisi",
	[1] = "id",
	[2] = "cast",
	[3] = "hurt",
	[4] = "buff",
	[5] = "misc",		-- 给missile和trap使用
	[6] = "action",
	[7]	= "loop",
}

SpineEntry = 
{
	filename = "csv/spine.csv",
	fmt = "nsss",
	[1] = "id",
	[2] = "json",
	[3] = "atlas",
	[4] = "animation",
}
																		
stageEntry = 
{
	filename = "csv/stage.csv",
	fmt = "niiss",
	[1]  = "id",
	[2]  = "nextId",
	[3]  = "type",
	[4]  = "name",
	[5]  = "desc",
}

chapterEntry = 
{
	filename = "csv/chapter.csv",
	fmt = "niiissisiiiiiiiiii",
	[1]  = "id",
	[2]	 = "stage_index",
	[3] =  "number",
	[4] = "firstId",
	[5]  = "name",
	[6]  = "desc",
	[7] = "default_section",
	[8] = "script",
	[9] = "req_level",
	[10] = "costCoin",
	[11] = "enemyCombat",
	[12] = "reqStageId",
	[13] = "reqStageStar",
	[14] = Array("achievements",5,0),
}

sectionEntry = 
{
	filename = "csv/section.csv",
	fmt = "nisi",
	[1]  = "id",
	[2]	 = "chapter_index",
	[3]  = "mapfile",
	[4] = "default_part",
}

partEntry = 
{
	filename = "csv/part.csv",
	fmt = "niiiii",
	[1]  = "id",
	[2]	 = "section_index",
	[3]  = "number",
	[4]  = "leftpos",
	[5]  = "rightpos",
	[6]  = "nextpart",
}