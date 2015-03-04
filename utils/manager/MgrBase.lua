local ManagerBase = class("ManagerBase")

function ManagerBase:ctor(behaviorName, depends, priority, conflictions)
	cc(self):addComponent("quick.components.behavior.EventProtocol"):exportMethods()
end

return ManagerBase