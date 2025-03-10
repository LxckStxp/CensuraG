-- Core/DependencyManager.lua: Module dependency management
local DependencyManager = {}
local logger = _G.CensuraG.Logger

-- Store registered dependencies
local dependencies = {}

-- Register a module as a dependency
function DependencyManager:Register(name, module)
    if not name or type(name) ~= "string" then
        logger:error("Invalid dependency name")
        return nil
    end
    
    if not module then
        logger:error("Cannot register nil module for dependency: %s", name)
        return nil
    end
    
    dependencies[name] = module
    logger:debug("Registered dependency: %s", name)
    
    return module
end

-- Get a registered dependency
function DependencyManager:Get(name)
    if not dependencies[name] then
        logger:error("Dependency not found: %s", name)
        return nil
    end
    
    return dependencies[name]
end

-- Check if a dependency exists
function DependencyManager:HasDependency(name)
    return dependencies[name] ~= nil
end

-- List all registered dependencies
function DependencyManager:ListDependencies()
    local list = {}
    for name, _ in pairs(dependencies) do
        table.insert(list, name)
    end
    return list
end

-- Remove a dependency
function DependencyManager:Remove(name)
    if not dependencies[name] then
        logger:warn("Cannot remove non-existent dependency: %s", name)
        return false
    end
    
    dependencies[name] = nil
    logger:debug("Removed dependency: %s", name)
    
    return true
end

-- Clear all dependencies
function DependencyManager:Clear()
    local count = 0
    for name, _ in pairs(dependencies) do
        count = count + 1
    end
    
    dependencies = {}
    logger:info("Cleared %d dependencies", count)
    
    return count
end

-- Register multiple dependencies at once
function DependencyManager:RegisterBatch(moduleTable)
    if not moduleTable or type(moduleTable) ~= "table" then
        logger:error("Invalid module table for batch registration")
        return 0
    end
    
    local count = 0
    for name, module in pairs(moduleTable) do
        if self:Register(name, module) then
            count = count + 1
        end
    end
    
    logger:info("Batch registered %d dependencies", count)
    return count
end

return DependencyManager
