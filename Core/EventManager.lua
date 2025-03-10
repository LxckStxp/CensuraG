-- Core/EventManager.lua
-- Centralized event handling with improved structure

local EventManager = {}
local logger = _G.CensuraG.Logger

local connections = {}
local events = {}

-- Private helper functions
local function ensureEventExists(eventName)
    if not events[eventName] then
        events[eventName] = { Name = eventName, Callbacks = {} }
        logger:debug("Created event: %s", eventName)
    end
    return events[eventName]
end

-- Connection management
function EventManager:Connect(signal, callback)
    if not signal or not callback then
        logger:warn("Invalid parameters for Connect")
        return nil
    end
    
    local connection = signal:Connect(callback)
    table.insert(connections, connection)
    logger:debug("Connected event. Total connections: %d", #connections)
    
    return connection
end

function EventManager:Disconnect(connection)
    if not connection then return false end
    
    for i, conn in ipairs(connections) do
        if conn == connection then
            conn:Disconnect()
            table.remove(connections, i)
            logger:debug("Disconnected event. Remaining: %d", #connections)
            return true
        end
    end
    
    logger:warn("Connection not found for disconnect")
    return false
end

function EventManager:DisconnectAll()
    local count = #connections
    
    for _, conn in ipairs(connections) do
        if conn.Connected then conn:Disconnect() end
    end
    
    connections = {}
    logger:info("Disconnected all (%d) connections", count)
    return count
end

-- Event creation and management
function EventManager:CreateEvent(eventName)
    if events[eventName] then
        logger:warn("Event %s already exists", eventName)
        return events[eventName]
    end
    
    return ensureEventExists(eventName)
end

function EventManager:SubscribeToEvent(eventName, callback)
    if not callback then
        logger:warn("Cannot subscribe nil callback to event: %s", eventName)
        return nil
    end
    
    local event = ensureEventExists(eventName)
    local id = tostring(callback)
    event.Callbacks[id] = callback
    
    logger:debug("Subscribed to %s; total: %d", eventName, self:GetSubscriberCount(eventName))
    return id
end

function EventManager:UnsubscribeFromEvent(eventName, callbackId)
    if not events[eventName] or not events[eventName].Callbacks[callbackId] then
        logger:warn("Event %s or callback %s not found", eventName, callbackId)
        return false
    end
    
    events[eventName].Callbacks[callbackId] = nil
    logger:debug("Unsubscribed from %s; remaining: %d", eventName, self:GetSubscriberCount(eventName))
    return true
end

function EventManager:FireEvent(eventName, ...)
    local event = ensureEventExists(eventName)
    local fired = 0
    
    for _, callback in pairs(event.Callbacks) do
        local success, err = pcall(callback, ...)
        if not success then
            logger:warn("Error in %s callback: %s", eventName, err)
        end
        fired = fired + 1
    end
    
    logger:debug("Fired %s to %d subscribers", eventName, fired)
    return fired
end

-- Event information
function EventManager:GetSubscriberCount(eventName)
    if not events[eventName] then
        return 0
    end
    
    local count = 0
    for _ in pairs(events[eventName].Callbacks) do 
        count = count + 1 
    end
    
    return count
end

function EventManager:ListEvents()
    local eventList = {}
    for name, _ in pairs(events) do
        table.insert(eventList, name)
    end
    return eventList
end

-- Event cleanup
function EventManager:ClearEventSubscribers(eventName)
    if not events[eventName] then
        logger:warn("No event %s to clear", eventName)
        return false
    end
    
    local count = self:GetSubscriberCount(eventName)
    events[eventName].Callbacks = {}
    
    logger:debug("Cleared %d subscribers from %s", count, eventName)
    return true
end

function EventManager:RemoveEvent(eventName)
    if not events[eventName] then
        logger:warn("Attempt to remove non-existent event: %s", eventName)
        return false
    end
    
    events[eventName] = nil
    logger:debug("Removed event: %s", eventName)
    return true
end

-- Event utilities
function EventManager:HasEvent(eventName)
    return events[eventName] ~= nil
end

function EventManager:HasSubscribers(eventName)
    return self:GetSubscriberCount(eventName) > 0
end

function EventManager:GetEventTable()
    -- Return a copy to prevent direct modification
    local copy = {}
    for name, event in pairs(events) do
        copy[name] = {
            Name = event.Name,
            SubscriberCount = self:GetSubscriberCount(name)
        }
    end
    return copy
end

return EventManager
