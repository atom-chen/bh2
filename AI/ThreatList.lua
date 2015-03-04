local  ThreatList = class("ThreatList")
ThreatList.__index = ThreatList


function ThreatList:ctor(pl)
	self._list  = {}
	self._player = pl
end

function ThreatList:add(enemy)
	self._list[enemy] = 0
end

function ThreatList:getMostNearly()
	local r = -1
	local pl = nil
	for k,_ in pairs(self._list) do
		local tmp = k:pos().x * k:pos().x + k:pos().y * k:pos().y
		if tmp > r then
			r = tmp
			pl = k
		end 
	end
	return pl
end

function ThreatList:remove(player)
	if self._list[player] then
		self._list[player] = nil
	end
end

function ThreatList:getAll()
	return self._list
end

return ThreatList