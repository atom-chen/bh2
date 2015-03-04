local  Motion = class("Motion")
Motion.__index = Motion

function Motion:ctor(type,pl)
	self._type = type
	self._player = pl
end
function Motion:start()
end
function Motion:stop()
end

function Motion:complate()
	return true;
end
return Motion