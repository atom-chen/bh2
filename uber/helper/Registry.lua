local Registry = class("Registry")
Registry.__index = Registry

function Registry:ctor(superCls)
	self._classes = {}
	self._superClass = superCls
end

function Registry:setSuper(super)
	self._superClass = super
end

function Registry:add(name)
	local super = self._superClass
	local cls = nil
	if super then
		cls = class(name,super)
		function cls.ctor(this)
			this.super.ctor(this)
		end
	else
		cls = class(name)
	end
	if cls then
		self._classes[name] = cls
	end
	return cls
end

function Registry:get(name,autoload)
	local cls = self._classes[name]
	if not cls and autoload then
		cls = self:add(name)
	end
	return cls
end

return Registry
