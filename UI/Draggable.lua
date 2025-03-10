-- UI/Draggable.lua
-- Draggable functionality

local Draggable = {}
local UserInputService = game:GetService("UserInputService")
local logger = _G.CensuraG.Logger
local EventManager = _G.CensuraG.EventManager
local ErrorHandler = _G.CensuraG.ErrorHandler

function Draggable.new(element, dragRegion, options)
	if not element then
		logger:error("Cannot create Draggable with nil element")
		return nil
	end
	options = options or {}
	local self = {
		Element = element,
		DragRegion = dragRegion or element,
		Dragging = false,
		DragStart = nil,
		StartPos = nil,
		Connections = {},
		Bounds = options.Bounds,
		OnDragStart = options.OnDragStart,
		OnDragEnd = options.OnDragEnd,
		OnDrag = options.OnDrag
	}
	
	table.insert(self.Connections, EventManager:Connect(UserInputService.InputChanged, function(input)
		if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - self.DragStart
			local newX = self.StartPos.X.Offset + delta.X
			local newY = self.StartPos.Y.Offset + delta.Y
			if self.Bounds then
				newX = math.clamp(newX, self.Bounds.MinX or 0, self.Bounds.MaxX or math.huge)
				newY = math.clamp(newY, self.Bounds.MinY or 0, self.Bounds.MaxY or math.huge)
			else
				local gui = _G.CensuraG.ScreenGui
				if gui then newX = math.clamp(newX, 0, gui.AbsoluteSize.X - element.Size.X.Offset)
				    newY = math.clamp(newY, 0, gui.AbsoluteSize.Y - element.Size.Y.Offset)
				end
			end
			self.Element.Position = UDim2.new(0, newX, 0, newY)
			if self.OnDrag then self.OnDrag(newX, newY, delta) end
		end
	end))
	
	table.insert(self.Connections, EventManager:Connect(self.DragRegion.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.Dragging = true
			self.DragStart = input.Position
			self.StartPos = self.Element.Position
			ErrorHandler:TryCatch(function() _G.CensuraG.WindowManager:BringToFront(self.Element.Parent) end, "Failed to bring window to front")
			if self.OnDragStart then self.OnDragStart() end
			logger:debug("Started dragging %s", tostring(self.Element))
		end
	end))
	
	table.insert(self.Connections, EventManager:Connect(self.DragRegion.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and self.Dragging then
			self.Dragging = false
			if self.OnDragEnd then self.OnDragEnd(self.Element.Position.X.Offset, self.Element.Position.Y.Offset) end
			logger:debug("Stopped dragging %s", tostring(self.Element))
		end
	end))
	
	table.insert(self.Connections, EventManager:Connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and self.Dragging then
			self.Dragging = false
			if self.OnDragEnd then self.OnDragEnd(self.Element.Position.X.Offset, self.Element.Position.Y.Offset) end
			logger:debug("Stopped dragging %s (global release)", tostring(self.Element))
		end
	end))
	
	function self:SetBounds(minX, minY, maxX, maxY)
		self.Bounds = { MinX = minX, MinY = minY, MaxX = maxX, MaxY = maxY }
		logger:debug("Set draggable bounds")
	end
	
	function self:Destroy()
		for _, conn in ipairs(self.Connections) do
			conn:Disconnect()
		end
		self.Connections = {}
		logger:debug("Draggable destroyed for %s", tostring(self.Element))
	end
	
	return self
end

return Draggable
