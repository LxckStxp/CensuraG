-- UI/UIElement.lua
-- Base class for UI elements

local UIElement = {}
UIElement.__index = UIElement

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local EventManager = _G.CensuraG.EventManager
local logger = _G.CensuraG.Logger

function UIElement.new(parent, x, y, width, height, options)
	assert(parent and parent.Instance, "Invalid parent")
	options = options or {}
	local frame = Utilities.createInstance("Frame", {
		Parent = parent.Instance,
		Position = UDim2.new(0, x or 0, 0, y or 0),
		Size = UDim2.new(0, width or 100, 0, height or 100),
		BackgroundTransparency = Styling.Transparency.ElementBackground,
		ZIndex = parent.Instance.ZIndex + 1,
		Name = options.Name or "UIElement"
	})
	Styling:Apply(frame, "Frame")
	local self = setmetatable({ Instance = frame, Parent = parent, Children = {}, Connections = {}, Id = Utilities.generateId(), Options = options }, UIElement)
	table.insert(self.Connections, EventManager:Connect(frame.AncestryChanged, function(_, newParent)
		if not newParent then self:Destroy() end
	end))
	table.insert(self.Connections, EventManager:SubscribeToEvent("ThemeChanged", function() self:UpdateTheme() end))
	return self
end

function UIElement:UpdateTheme()
	Styling:Apply(self.Instance, "Frame")
	logger:debug("Updated theme for UIElement %s", self.Instance.Name)
end

function UIElement:AddChild(child)
	if child then table.insert(self.Children, child); logger:debug("Added child to %s", self.Instance.Name) end
	return true
end

function UIElement:RemoveChild(child)
	for i, c in ipairs(self.Children) do
		if c == child then table.remove(self.Children, i); logger:debug("Removed child from %s", self.Instance.Name); return true end
	end
	return false
end

function UIElement:SetPosition(x, y)
	self.Instance.Position = UDim2.new(0,x,0,y)
	logger:debug("Set position of %s to (%d, %d)", self.Instance.Name, x, y)
end

function UIElement:SetSize(width, height)
	self.Instance.Size = UDim2.new(0,width,0,height)
	logger:debug("Set size of %s to (%d, %d)", self.Instance.Name, width, height)
end

function UIElement:SetVisible(visible)
	self.Instance.Visible = visible
	logger:debug("Set visibility of %s to %s", self.Instance.Name, tostring(visible))
end

function UIElement:SetZIndex(zIndex)
	self.Instance.ZIndex = zIndex
	for _, child in ipairs(self.Children) do
		if child.SetZIndex then child:SetZIndex(zIndex+1) end
	end
	logger:debug("Set ZIndex of %s to %d", self.Instance.Name, zIndex)
end

function UIElement:Destroy()
	for _, child in ipairs(self.Children) do
		if child.Destroy then child:Destroy() end
	end
	self.Children = {}
	for _, conn in ipairs(self.Connections) do
		pcall(function() conn:Disconnect() end)
	end
	self.Connections = {}
	if _G.CensuraG.Animation then _G.CensuraG.Animation:CleanupHoverEffects(self.Instance) end
	if self.Instance then self.Instance:Destroy() end
	logger:info("UIElement destroyed: %s", self.Id)
end

return UIElement
