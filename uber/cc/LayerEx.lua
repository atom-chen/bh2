local c = cc
local Layer = cc.Layer

function Layer:onTouchBegan(x,y)
	return true
end

function Layer:onTouchEnded(x,y)
end

function Layer:onTouchMoved(x,y)
end

function Layer:onTouchCancelled(x,y)
end

function Layer:setLayerEventEnabled(enabled, handler)
    if enabled then
    	self:setTouchEnabled(true)
        if not handler then
            handler = function(event,x,y)
                if event == "began" then
                   return self:onTouchBegan(x,y)
                elseif event == "moved" then
                    self:onTouchMoved(x,y)
                elseif event == "ended" then
                    self:onTouchEnded(x,y)
                elseif event == "cancelled" then
                    self:onTouchCancelled(x,y)
                end
            end
        end
        self:registerScriptTouchHandler(handler)
    else
    	self:setTouchEnabled(false)
        self:unregisterScriptTouchHandler()
    end
    return self
end