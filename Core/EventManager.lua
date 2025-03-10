-- Core/EventManager.lua
-- Centralized event handling

local EventManager = {}
local logger = _G.CensuraG.Logger

local connections = {}
local events = {}

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

function EventManager:CreateEvent(eventName)
	if events[eventName] then
		logger:warn("Event %s already exists", eventName)
		return events[eventName]
	end
	events[eventName] = { Name = eventName, Callbacks = {} }
	logger:debug("Created event: %s", eventName)
	return events[eventName]
end

function EventManager:SubscribeToEvent(eventName, callback)
	if not events[eventName] then
		events[eventName] = self:CreateEvent(eventName)
	end
	local id = tostring(callback)
	events[eventName].Callbacks[id] = callback
	logger:debug("Subscribed to %s; total: %d", eventName, self:GetSubscriberCount(eventName))
	return id
end

function EventManager:UnsubscribeFromEvent(eventName, callbackId)
	if events[eventName] and events[eventName].Callbacks[callbackId] then
		events[eventName].Callbacks[callbackId] = nil
		logger:debug("Unsubscribed from %s; remaining: %d", eventName, self:GetSubscriberCount(eventName))
		return true
	else
		logger:warn("Event %s or callback %s not found", eventName, callbackId)
		return false
	end
end

function EventManager:FireEvent(eventName, ...)
	if not events[eventName] then
		logger:warn("Attempt to fire non-existent event: %s", eventName)
		return 0
	end
	local fired = 0
	for _, callback in pairs(events[eventName].Callbacks) do
		local success, err = pcall(callback, ...)
		if not success then
			logger:warn("Error in %s callback: %s", eventName, err)
		end
		fired = fired + 1
	end
	logger:debug("Fired %s to %d subscribers", eventName, fired)
	return fired
end

function EventManager:GetSubscriberCount(eventName)
	if events[eventName] then
		local count = 0
		for _ in pairs(events[eventName].Callbacks) do count = count + 1 end
		return count
	end
	return 0
end

function EventManager:ClearEventSubscribers(eventName)
	if events[eventName] then
		local count = self:GetSubscriberCount(eventName)
		events[eventName].Callbacks = {}
		logger:debug("Cleared %d subscribers from %s", count, eventName)
		return true
	else
		logger:warn("No event %s to clear", eventName)
		return false
	end
end

function EventManager:RemoveEvent(eventName)
	if events[eventName] then
		events[eventName] = nil
		logger:debug("Removed event: %s", eventName)
		return true
	else
		logger:warn("Attempt to remove non-existent event: %s", eventName)
		return false
	end
end

return EventManager
