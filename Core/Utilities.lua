-- Core/Utilities.lua: Simplified utility functions
local Utilities = {}

-- Create an instance with properties
function Utilities.createInstance(className, properties)
    local inst = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        inst[prop] = value
    end
    return inst
end

return Utilities
