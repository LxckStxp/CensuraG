-- Core/DependencyManager.lua: Simplified dependency management
local DependencyManager = {}
local dependencies = {}

-- Register a module
function DependencyManager:Register(name, module)
    if name and module then
        dependencies[name] = module
    end
end

-- Get a registered module
function DependencyManager:Get(name)
    return dependencies[name]
end

return DependencyManager
