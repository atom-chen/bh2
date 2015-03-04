local HexData = class("HexData")
HexData.__index = HexData

function HexData:ctor(dec)
	--assert(type(dec) == "number","invalid param")
	if type(dec) == "number" then
		self._value = string.format("%x",dec)
	elseif type(dec) == "string" then
		self._value = dec
	else
		assert(false)
	end
end

function HexData:HexToDec()
	local ret = 0
	for i = 1,string.len(self._value) do
		local char = string.sub(self._value,i,i)
		char = string.upper(char)
		if char >= '0' and char <= '9' then
			ret = ret * 16 + (char - '0')
		elseif char >= 'A' and char <= 'Z' then
			ret = ret * 16 + (string.byte(char) - string.byte('A') + 10)
		end
	end

	return ret
end

function HexData:GetInt( )
	return self:HexToDec()
end

function HexData:GetString()
	return self._value
end

function HexData:setValue( val )
	if type(val) == "number" then
		self._value = string.format("%x",val)
	elseif type(val) == "string" then
		self._value = val
	end
end

return HexData