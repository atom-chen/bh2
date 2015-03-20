require("Data.csv.CSVStruture")
local csvloader = require("uber.csv.CSVLoader")
uber.TimingBegin()
sAchievementStore = csvloader.load(AchievementEntry)
sCreatureStore = csvloader.load( CreatureInfoEntry )
sPlayerDisplayStore = csvloader.load(PlayerDisplayEntry)
sPlayerCreateInfoStore = csvloader.load(PlayerCreateInfoEntry)
sLocalePlayerStore = csvloader.load(LocalePlayerEntry)
sHireCostStore = csvloader.load(HireCostEntry)
sItemStore = csvloader.load(ItemTemplateEntry)
sItemRandomWordStore = csvloader.load(ItemRandomWordEntry)
sItemVerifyStore = csvloader.load(ItemVerifyEntry)
sLootWordStore = csvloader.load(LootWordEntry)
sLootQualityStore = csvloader.load(LootQualityEntry)
sLevelExpStore = csvloader.load(LevelExpEntry)
uber.TimingEnd()
--sDisplayStore = dbcloader.load( DisplayEntry )
sPhysicsInfo = csvloader.load( PhysicsInfo )
sMiscValueInfo = csvloader.load(MiscValueInfo)

sSpellIconStore = csvloader.load( SpellIconEntry )
sSpellEntry = csvloader.load( SpellEntry )
sSpellChainStore = csvloader.load(SpellChainEntry)
sSpellLocaleStore = csvloader.load(LocaleSpellEntry)
sSpellEffects= csvloader.load( SpellEffects)
sSpellMoves = csvloader.load( SpellMoves )

sSpellDisplayStore = csvloader.load(SpellDisplayEntry)
sSpineStore = csvloader.load(SpineEntry)


-- 关卡数据 -------------------------
sStageStore = csvloader.load( stageEntry )
sChapterStore = csvloader.load( chapterEntry )
sSectionStore = csvloader.load( sectionEntry )
sPartStore = csvloader.load( partEntry )
----------------------------------


sItemLootStroes = csvloader.load( LootTemplateEntry )