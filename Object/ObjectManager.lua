faceleft = faceleft or -1
faceright = faceright or 1

PlayerType = 1 		-- 玩家
MonsterType = 2  	-- 怪物
ObjectType = 3 		-- 场景物件
MissileType = 4 	-- 飞行道具
TrapType = 5 		-- 陷阱类
ItemType = 6 		-- 道具

ObjectManager = ObjectManager or {}

ObjectManager._info = {}

function ObjectManager:addInfo(info)
	self._info[info.id] = info
end


function ObjectManager:getInfo(id)
	return clone(self._info[id])
end