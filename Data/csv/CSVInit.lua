require("Data.csv.CSVStruture")
local csvloader = require("uber.csv.CSVLoader")
uber.TimingBegin()
sCreatureStore = csvloader.load( CreatureInfoEntry )
uber.TimingEnd()
--sDisplayStore = dbcloader.load( DisplayEntry )
sPhysicsInfo = csvloader.load( PhysicsInfo )
sMiscValueInfo = csvloader.load(MiscValueInfo)

sSpellEntry = csvloader.load( SpellEntry )
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

