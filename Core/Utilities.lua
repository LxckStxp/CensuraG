-- Core/Utilities.lua
-- Helper functions

local Utilities = {}
local logger = _G.CensuraG.Logger

function Utilities.createInstance(className, properties)
	local success, instance = pcall(function()
		local obj = Instance.new(className)
		if properties then
			for prop, value in pairs(properties) do
				obj[prop] = value
			end
		end
		return obj
	end)
	if not success then
		logger:error("Failed to create %s: %s", className, tostring(instance))
		return nil
	end
	return instance
end

function Utilities.deepCopy(orig)
	if type(orig) ~= "table" then return orig end
	local copy = {}
	for k, v in pairs(orig) do
		copy[k] = Utilities.deepCopy(v)
	end
	return copy
end

function Utilities.formatNumber(num)
	local str = tostring(num)
	while true do
		str, n = string.gsub(str, "^(-?%d+)(%d%d%d)", '%1,%2')
		if n == 0 then break end
	end
	return str
end

function Utilities.truncateText(text, maxLength)
	if #text <= maxLength then return text end
	return string.sub(text, 1, maxLength - 3) .. "..."
end

function Utilities.getScreenSize()
	if _G.CensuraG and _G.CensuraG.ScreenGui then
		return _G.CensuraG.ScreenGui.AbsoluteSize
	end
	return Vector2.new(1366,768)
end

function Utilities.isPointInElement(element, point)
	if not element or not element.AbsolutePosition or not element.AbsoluteSize then return false end
	local pos, size = element.AbsolutePosition, element.AbsoluteSize
	return point.X >= pos.X and point.X <= pos.X + size.X and point.Y >= pos.Y and point.Y <= pos.Y + size.Y
end

function Utilities.generateId()
	return string.format("%x", os.time() + math.random(1, 1000000))
end

function Utilities.getPlayerAvatar(userId, size)
	size = size or Enum.ThumbnailSize.Size100x100
	local Players = game:GetService("Players")
	local success, url = pcall(function()
		return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.AvatarBust, size)
	end)
	if success then return url else logger:warn("Failed to get avatar for %s", tostring(userId)); return "rbxassetid://0" end
end

return Utilities
