require("uber.dbc.DBCStores")

CreatureInfoEntry = 
{
	filename = "csv/creature.csv",
	fmt 	 = "niiiiiiiiiiiiiiiiiiiiiiiii",
	[1]  = "id",
	[2]  = "display",
	[3]	 = "hp",
	[4]  = "maphp",
	[5]  = "mp",
	[6]  = "maxmp",
	[7]	 = "armor",
	[8]	 = "resist",
	[9]	 = "speedX",
	[10] = "speedY",
	[11] = "kdValue",
	[12] = "kbValue",
	[13] = "resistKd",
	[14] = "resistKb",
	[15] = "recoverKd",
	[16] = "recoverKb",
	[17] = "downSpeed",
	[18] = "fallSpeed",
	[19] = "downTime",
	[20] = Array("attack",3,""),
	[21] = Array("skill",4,""),
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
	fmt = "niiisi",
	[1] = "id",
	[2] = "cast",
	[3] = "hurt",
	[4] = "buff",
	[5] = "action",
	[6]	= "loop",
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
	fmt = "niss",
	[1]  = "id",
	[2]  = "nextId",
	[3]  = "name",
	[4]  = "desc",
}

chapterEntry = 
{
	filename = "csv/chapter.csv",
	fmt = "niissis",
	[1]  = "id",
	[2]	 = "stage_index",
	[3] =  "number",
	[4]  = "name",
	[5]  = "desc",
	[6] = "default_section",
	[7] = "script"
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