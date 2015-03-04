--BaseChapterScript

BaseChapterScript = BaseChapterScript or {}

-- 地图事件定义

-- 地图怪物定义

-- 地图计时器定义

function BaseChapterScript:ctor()
	self._scriptMgr = nil
end


function BaseChapterScript:setScript(scriptMgr)
	self._scriptMgr = scriptMgr
end

function BaseChapterScript:script()
	return self._scriptMgr
end

-- 读取地图
function BaseChapterScript:Load()
	
end

-- 创建段
function BaseChapterScript:InitPart()
	
end

-- 更新
function BaseChapterScript:update(dt)
	
end

-- 进入场景
function BaseChapterScript:EnterChapter()
end

-- 退出场景
function BaseChapterScript:CloseChapter()
end



CREATE_CHAPTER_SCRIPT = function()
	return clone(BaseChapterScript)
end