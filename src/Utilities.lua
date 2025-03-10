-- Utilities.lua: Reusable helper functions
local Utilities = {}

function Utilities.createInstance(className, properties)
    local instance = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        instance[prop] = value
    end
    return instance
end

return Utilities
