
local function getNumber(value)
    local ret = tonumber(value)
    ret = ret or 0
    return ret
end

local function getString(value)
    if type(value) == "string" then
        return value
    else
        --cclog("CSVloader解析到一个不是string的类型要求返回字符串,返回默认空串")
        return ""
    end
end

local function getBoolean( value )
	value = tonumber(value)
	assert(value == 0 or value == 1,"布尔型值只允许配1或0")
	if value == 0 then
		value = false
	else
		value = true
	end
	return value
end

local CSVformat =
{
	["n"] = {handler = getNumber,size = 4},
    ["i"] = {handler = getNumber,size = 4},
    ["s"] = {handler = getString,size = 4},
    ["b"] = {handler = getBoolean}
}

local function load( entry )
	local t = require(entry.filename)
	local newT = {}
	for i=1,#t do
		local info = t[i]
		if newT[info.id] then assert(false,"ERROR:" .. entry.filename .."表中存在重复的Id:"..info.id) end
		assert(table.nums(info) == string.len(entry.fmt),entry.filename.."字段数不统一")
		--local idx = 1
		for k,value in pairs(info) do
			--local fmt = string.sub(entry.fmt,idx,idx)
			--CSVformat[fmt].handler(value)
			--idx = idx + 1
			if value == "" then
				value = 0
			end
		end
		newT[info.id] = info
	end
	return newT
end

uber.TimingBegin()
sCreatureStore = load( CreatureInfoEntry )

--sDisplayStore = dbcloader.load( DisplayEntry )
sPhysicsInfo = load( PhysicsInfo )
sMiscValueInfo = load(MiscValueInfo)

sSpellEntry = load( SpellEntry )
sSpellEffects= load( SpellEffects)
sSpellMoves = load( SpellMoves )

sSpellDisplayStore = load(SpellDisplayEntry)
sSpineStore = load(SpineEntry)


-- 关卡数据 -------------------------
sStageStore = load( stageEntry )
sChapterStore = load( chapterEntry )
sSectionStore = load( sectionEntry )
sPartStore = load( partEntry )
----------------------------------

uber.TimingEnd()