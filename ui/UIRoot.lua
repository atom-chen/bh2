local UIRoot = class("UIRoot",function ()
	return ccui.layer()
end)
UIRoot.__index = UIRoot

function UIRoot:LoadUI( filename )
	
end

return UIRoot
