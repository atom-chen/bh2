faceleft = faceleft or -1
faceright = faceright or 1

PlayerType = 1
MonsterType = 2
ObjectType = 3
ItemType = 4

ObjectManager = ObjectManager or {}

ObjectManager._info = {}

function ObjectManager:addInfo(info)
	self._info[info.id] = info
end


function ObjectManager:getInfo(id)
	return clone(self._info[id])
end