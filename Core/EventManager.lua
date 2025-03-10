-- Core/EventManager.lua: Centralized event handling system
local EventManager = {}
local logger = _G.CensuraG.Logger

-- Store all connections for cleanup
local connections = {}

-- Store custom events
local events = {}

-- Connect to a Roblox event and track the connection
function EventManager:Connect(signal, callback)
    if not signal or not callback then
        logger:warn("Invalid parameters for Connect")
        return nil
    end
    
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    logger:debug("Connected to event, total connections: %d", #connections)
    
    return connection
end

-- Disconnect a specific connection
function EventManager:Disconnect(connection)
    if not connection then return false end
    
    for i, conn in ipairs(connections) do
        if conn == connection then
            conn:Disconnect()
            table.remove(connections, i)
            logger:debug("Disconnected event, remaining connections: %d", #connections)
            return true
        end
    end
    
    logger:warn("Connection not found for disconnection")
    return false
end

-- Disconnect all tracked connections
function EventManager:DisconnectAll()
    local count = #connections
    for _, connection in ipairs(connections) do
        if connection.Connected then
            connection:Disconnect()
        end
    end
    
    connections = {}
    logger:info("Disconnected all %d connections", count)
    return count
end

-- Create a custom event
function EventManager:CreateEvent(eventName)
    if events[eventName] then
        logger:warn("Event %s already exists", eventName)
        return events[eventName]
    end
    
    local event = {
        Name = eventName,
        Callbacks = {}
    }
    
    events[eventName] = event
    logger:debug("Created custom event: %s", eventName)
    
    return event
end

-- Subscribe to a custom event
function EventManager:SubscribeToEvent(eventName, callback)
    if not events[eventName] then
        events[eventName] = self:CreateEvent(eventName)
    end
    
    local callbackId = tostring(callback)
    events[eventName].Callbacks[callbackId] = callback
    logger:debug("Subscribed to event %s, total subscribers: %d", 
        eventName, self:GetSubscriberCount(eventName))
    
    return callbackId
end

-- Unsubscribe from a custom event
function EventManager:UnsubscribeFromEvent(eventName, callbackId)
    if not events[eventName] or not events[eventName].Callbacks[callbackId] then
        logger:warn("Event %s or callback %s not found", eventName, callbackId)
        return false
    end
    
    events[eventName].Callbacks[callbackId] = nil
    logger:debug("Unsubscribed from event %s, remaining subscribers: %d", 
        eventName, self:GetSubscriberCount(eventName))
    
    return true
end

-- Fire a custom event
function EventManager:FireEvent(eventName, ...)
    if not events[eventName] then
        logger:warn("Attempted to fire non-existent event: %s", eventName)
        return 0
    end
    
    local count = 0
    for _, callback in pairs(events[eventName].Callbacks) do
        local success, err = pcall(callback, ...)
        if not success then
            logger:warn("Error in event %s callback: %s", eventName, err)
        end
        count = count + 1
    end
    
    logger:debug("Fired event %s to %d subscribers", eventName, count)
    return count
end

-- Get subscriber count for an event
function EventManager:GetSubscriberCount(eventName)
    if not events[eventName] then return 0 end
    
    local count = 0
    for _ in pairs(events[eventName].Callbacks) do
        count = count + 1
    end
    
    return count
end

-- Clear all subscribers for an event
function EventManager:ClearEventSubscribers(eventName)
    if not events[eventName] then
        logger:warn("Attempted to clear non-existent event: %s", eventName)
        return false
    end
    
    local count = self:GetSubscriberCount(eventName)
    events[eventName].Callbacks = {}
    logger:debug("Cleared %d subscribers from event %s", count, eventName)
    
    return true
end

-- Remove an event completely
function EventManager:RemoveEvent(eventName)
    if not events[eventName] then
        logger:warn("Attempted to remove non-existent event: %s", eventName)
        return false
    end
    
    events[eventName] = nil
    logger:debug("Removed event: %s", eventName)
    
    return true
end

return EventManager
