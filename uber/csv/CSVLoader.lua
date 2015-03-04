local CSVLoader = CSVLoader or {}

local function getNumber(value)
    local ret = tonumber(value)
    ret = ret or 0
    return ret
end

local function getString(value)
    if type(value) == "string" then
        return value
    else
        cclog("CSVloader解析到一个不是string的类型要求返回字符串,返回默认空串")
        return ""
    end
end

local CSVformat =
{
	["n"] = {handler = getNumber,size = 4},
    ["i"] = {handler = getNumber,size = 4},
    ["s"] = {handler = getString,size = 4},
}

function CSVLoader.load(entry)
    local dbcStore = {}
	local filename = cc.getFullPath(entry.filename)
	if cc.isFileExist(filename) == false then
         cclog("required csv : "..entry.filename.." not found")
         return nil
    end
    cclog("load csv "..filename)

    local data2 = sharedFileUtils:getStringFromFile(filename) --cc.HelperFunc:getFileData(filename)
    --print(data2)
    assert(data2 ~= "", filename .. "无法读取内容。尝试用nodepad++把文件转换为UTF无BOM编码")
    local data = string.split(data2,"\n")
    filename = entry.filename

    entry.filename = nil		-- 删除filename字段

    local fmtLen = string.len(entry.fmt)
    local fmtTable = {}
    local oneRecordSize = 0
    local indexpos = -1
    for i=1,fmtLen do
    	fmtTable[i] = string.sub(entry.fmt,i,i)
    	if fmtTable[i] == "n" then
    		indexpos = oneRecordSize
    	end
    	oneRecordSize = oneRecordSize + CSVformat[fmtTable[i]].size
    end
    entry.fmt = nil 			-- 删除fmt字段

    local lineStr = string.trim(data[1])
    local tmp = string.split(lineStr, ",")
    local fieldCount = #tmp

    if fieldCount ~= #fmtTable then
        cclog("CSV "..filename.." exist but have "..fieldCount.." fields instead "..#fmtTable)
        return nil
    end

    function setValue(dstTable,srcTable,valueTable,deep)
        local step = 0
        for k,v in ipairs(srcTable) do
            if type(v) == "table" then
                local tempTable = {}        
                if v.name then                      -- 表有名字,是一个数组
                    dstTable[v.name] = tempTable
                else
                    dstTable[k-1] = tempTable       -- 表没名字,说明是一个结构体
                end
                step = step + setValue(tempTable,v,valueTable,step+deep)
            else
                step = step + 1
                fmt = fmtTable[step+deep]
                if type(v) == "number" or v == "" then
                    dstTable[k-1] = valueTable[step+deep]
                    if fmt ~= "s" then
                        dstTable[k-1] = CSVformat[fmt].handler(valueTable[step+deep])
                    end
                else
                    if fmt == "s" then
                        dstTable[v] = CSVformat[fmt].handler(valueTable[step+deep])
                    else
                        dstTable[v] = CSVformat[fmt].handler(valueTable[step+deep])
                    end
                end
            end
        end
        return step
    end

    for i = 1,#data do
        while true do
            if i == 1 then break end
            local lineStr = string.trim(data[i])
            local tmp = string.split(lineStr, ",")
            if #tmp < 1 then break end
            local id = tonumber(tmp[1])
            if not id then break end
            if not dbcStore[id] then dbcStore[id] = {} end
            if dbcStore[id] then
                setValue(dbcStore[id],entry,tmp,0)
            end
            break
        end
    end

    assert(table.nums(dbcStore) ~= 0,"读取出错。检查配置表是否为空")
    return dbcStore
end

return CSVLoader