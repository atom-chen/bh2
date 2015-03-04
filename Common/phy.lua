--phy
local phy = {}

function phy:ctor()
	
end

--[[
计算抛物落体位移
s=v0t - at2
]]
function phy:calcS(v0,a,t)
	local s = v0 * t - a * t * t
	return s
end

--[[
计算抛物落体最高点时间
1阶导数为0时的T值
s' = v0-2at = 0
t = v0/2a
]]
function phy:calcMaxS_T(v0,a)
	local t = v0 / (2.0 * a)
	return t
end

--[[
计算抛物落体总时间
v0t = at2
t = v0/a
]]
function phy:calcTotal_T(v0,a)
	local t = v0 / a
	return t
end

--[[
计算抛物线最高点的Y值]]
function phy:calcMaxS(v0,a)
	local s = v0*v0 / (4.0*a)	
	return s
end

--[[
计算自由落体时间
s = at2

]]
function phy:calcFreeFallT(s,a)
	local t = math.sqrt(s/a)
	return t
end



return phy