-- Core/EventManager.lua: Simplified event handling
local EventManager = {}
local connections = {}

-- Connect to an event
function EventManager:Connect(signal, callback)
    if signal and callback then
        local connection = signal:Connect(callback)
        table.insert(connections, connection)
        return connection
    end
end

-- Disconnect all connections
function EventManager:DisconnectAll()
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    connections = {}
end

return EventManager
