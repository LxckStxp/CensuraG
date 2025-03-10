-- Core/DependencyManager.lua
-- Module dependency management with registration and retrieval

local DependencyManager = {}
local logger = _G.CensuraG.Logger

local dependencies = {}

function DependencyManager:Register(name, module)
	if type(name) ~= "string" or not module then
		logger:error("Invalid dependency registration: name=%s, module=%s", tostring(name), tostring(module))
		return nil
	end
	dependencies[name] = module
	logger:debug("Registered dependency: %s", name)
	return module
end

function DependencyManager:Get(name)
	if not dependencies[name] then
		logger:error("Dependency not found: %s", name)
		return nil
	end
	return dependencies[name]
end

function DependencyManager:HasDependency(name)
	return dependencies[name] ~= nil
end

function DependencyManager:ListDependencies()
	local list = {}
	for name, _ in pairs(dependencies) do
		table.insert(list, name)
	end
	return list
end

function DependencyManager:Remove(name)
	if not dependencies[name] then
		logger:warn("Cannot remove non-existent dependency: %s", name)
		return false
	end
	dependencies[name] = nil
	logger:debug("Removed dependency: %s", name)
	return true
end

function DependencyManager:Clear()
	local count = 0
	for _ in pairs(dependencies) do count = count + 1 end
	dependencies = {}
	logger:info("Cleared %d dependencies", count)
	return count
end

function DependencyManager:RegisterBatch(moduleTable)
	if type(moduleTable) ~= "table" then
		logger:error("Invalid module table for batch registration")
		return 0
	end
	local count = 0
	for name, module in pairs(moduleTable) do
		if self:Register(name, module) then count = count + 1 end
	end
	logger:info("Batch registered %d dependencies", count)
	return count
end

return DependencyManager
