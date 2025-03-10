-- Elements/Window.lua
-- Enhanced window element

local Window = setmetatable({}, { __index = _G.CensuraG.UIElement })
Window.__index = Window

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local Draggable = _G.CensuraG.Draggable
local EventManager = _G.CensuraG.EventManager
local logger = _G.CensuraG.Logger

function Window.new(title, x, y, width, height, options)
	options = options or {}
	width = width or 300
	height = height or 200
	
	local frame = Utilities.createInstance("Frame", {
		Parent = _G.CensuraG.ScreenGui,
		Position = UDim2.new(0, x or 100, 0, y or 100),
		Size = UDim2.new(0, width, 0, height),
		ZIndex = 10,
		Name = "Window_"..(options.Name or title or "Unnamed")
	})
	Styling:Apply(frame, "Window")
	
	local shadow = Utilities.createTaperedShadow(frame, 5, 5, 0.9)
	shadow.ZIndex = frame.ZIndex - 1
	
	local titleBarHeight = 25
	local titleBar = Utilities.createInstance("Frame", {
		Parent = frame,
		Position = UDim2.new(0,0,0,0),
		Size = UDim2.new(1,0,0,titleBarHeight),
		BackgroundColor3 = Styling.Colors.Secondary,
		BackgroundTransparency = Styling.Transparency.ElementBackground - 0.1,
		ZIndex = frame.ZIndex + 1,
		Name = "TitleBar"
	})
	Styling:Apply(titleBar, "Frame")
	
	local titleText = Utilities.createInstance("TextLabel", {
		Parent = titleBar,
		Position = UDim2.new(0,10,0,0),
		Size = UDim2.new(1,-80,1,0),
		Text = title or "Window",
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		ZIndex = titleBar.ZIndex + 1,
		Name = "TitleText"
	})
	Styling:Apply(titleText, "TextLabel")
	
	local buttonSize = titleBarHeight - 6
	local minimizeButton = Utilities.createInstance("TextButton", {
		Parent = titleBar,
		Position = UDim2.new(1, -buttonSize*2 - 8, 0, 3),
		Size = UDim2.new(0, buttonSize, 0, buttonSize),
		Text = "-",
		ZIndex = titleBar.ZIndex + 1,
		Name = "MinimizeButton"
	})
	Styling:Apply(minimizeButton, "TextButton")
	Animation:HoverEffect(minimizeButton)
	
	local maximizeButton = Utilities.createInstance("TextButton", {
		Parent = titleBar,
		Position = UDim2.new(1, -buttonSize - 5, 0, 3),
		Size = UDim2.new(0, buttonSize, 0, buttonSize),
		Text = "□",
		ZIndex = titleBar.ZIndex + 1,
		Name = "MaximizeButton"
	})
	Styling:Apply(maximizeButton, "TextButton")
	Animation:HoverEffect(maximizeButton)
	
	local contentContainer = Utilities.createInstance("Frame", {
		Parent = frame,
		Position = UDim2.new(0,5,0,titleBarHeight+5),
		Size = UDim2.new(1,-10,1,-titleBarHeight-10),
		BackgroundTransparency = 1,
		ZIndex = frame.ZIndex + 1,
		Name = "ContentContainer"
	})
	
	local self = setmetatable({
		Instance = frame, Shadow = shadow, TitleBar = titleBar, TitleText = titleText,
		MinimizeButton = minimizeButton, MaximizeButton = maximizeButton, ContentContainer = contentContainer,
		Minimized = false, Maximized = false, CurrentPosition = frame.Position,
		OriginalPosition = frame.Position, OriginalSize = frame.Size, DragHandler = nil, Id = Utilities.generateId(),
		Options = options
	}, Window)
	
	self.DragHandler = Draggable.new(frame, titleBar, {
		OnDragStart = function() EventManager:FireEvent("WindowDragStart", self) end,
		OnDragEnd = function() EventManager:FireEvent("WindowDragEnd", self) end
	})
	
	if _G.CensuraG.WindowManager then
		_G.CensuraG.WindowManager:AddWindow(self)
	end
	
	minimizeButton.MouseButton1Click:Connect(function() self:Minimize() end)
	maximizeButton.MouseButton1Click:Connect(function()
		if self.Maximized then self:Restore() else self:Maximize() end
	end)
	
	if options.Modal then self:SetModal(true) end
	if options.Resizable ~= false then self:MakeResizable() end
	
	logger:info("Created window: %s", title or "Unnamed")
	EventManager:FireEvent("WindowCreated", self)
	return self
end

function Window:Minimize()
	if self.Minimized then return end
	self.Minimized = true
	self.CurrentPosition = self.Instance.Position
	local screenHeight = _G.CensuraG.ScreenGui.AbsoluteSize.Y
	Animation:SlideY(self.Instance, screenHeight+50, 0.3, nil, nil, function()
		self.Instance.Visible = false
		self.Shadow.Visible = false
		self.Minimized = true
		EventManager:FireEvent("WindowMinimized", self)
	end)
	Animation:SlideY(self.Shadow, screenHeight+45, 0.3)
	if _G.CensuraG.Taskbar then _G.CensuraG.Taskbar:AddWindow(self) end
end

function Window:Maximize()
	if self.Minimized then self:Restore(function() self:Maximize() end); return end
	if self.Maximized then return end
	self.OriginalPosition = self.Instance.Position
	self.OriginalSize = self.Instance.Size
	local screenSize = _G.CensuraG.Utilities.getScreenSize()
	Animation:Tween(self.Instance, { Position = UDim2.new(0,0,0,0), Size = UDim2.new(0, screenSize.X, 0, screenSize.Y-40) }, 0.3, nil, nil, function()
		self.Maximized = true
		EventManager:FireEvent("WindowMaximized", self)
	end)
	Animation:Tween(self.Shadow, { Position = UDim2.new(0,-5,0,-5), Size = UDim2.new(0, screenSize.X+10, 0, screenSize.Y-30) }, 0.3)
end

function Window:Restore(callback)
	if not self.Minimized and not self.Maximized then return end
	if self.Minimized then
		self.Instance.Visible = true
		self.Shadow.Visible = true
		local targetY = self.CurrentPosition.Y.Offset
		Animation:SlideY(self.Instance, targetY, 0.3, nil, nil, function()
			self.Minimized = false
			EventManager:FireEvent("WindowRestored", self)
			if callback then callback() end
		end)
		Animation:SlideY(self.Shadow, self.CurrentPosition.Y.Offset-5, 0.3)
		if _G.CensuraG.Taskbar then _G.CensuraG.Taskbar:RemoveWindow(self) end
	elseif self.Maximized then
		Animation:Tween(self.Instance, { Position = self.OriginalPosition, Size = self.OriginalSize }, 0.3, nil, nil, function()
			self.Maximized = false
			EventManager:FireEvent("WindowRestored", self)
			if callback then callback() end
		end)
		Animation:Tween(self.Shadow, { Position = UDim2.new(0, self.OriginalPosition.X.Offset-5,0, self.OriginalPosition.Y.Offset-5),
										 Size = UDim2.new(0, self.OriginalSize.X.Offset+10,0, self.OriginalSize.Y.Offset+10) }, 0.3)
	end
end

function Window:MakeResizable()
	local resizeHandleSize = 10
	local minWidth, minHeight = 200, 100
	local handles = {
		Utilities.createInstance("TextButton", {
			Parent = self.Instance,
			Position = UDim2.new(1,-resizeHandleSize,1,-resizeHandleSize),
			Size = UDim2.new(0,resizeHandleSize,0,resizeHandleSize),
			Text = "",
			BackgroundTransparency = 1,
			ZIndex = self.Instance.ZIndex + 2,
			Name = "ResizeHandleBR"
		}),
		Utilities.createInstance("TextButton", {
			Parent = self.Instance,
			Position = UDim2.new(0, resizeHandleSize, 1, -resizeHandleSize),
			Size = UDim2.new(1, -resizeHandleSize*2, 0, resizeHandleSize),
			Text = "",
			BackgroundTransparency = 1,
			ZIndex = self.Instance.ZIndex + 2,
			Name = "ResizeHandleB"
		}),
		Utilities.createInstance("TextButton", {
			Parent = self.Instance,
			Position = UDim2.new(1,-resizeHandleSize,0, resizeHandleSize),
			Size = UDim2.new(0,resizeHandleSize,1, -resizeHandleSize*2),
			Text = "",
			BackgroundTransparency = 1,
			ZIndex = self.Instance.ZIndex + 2,
			Name = "ResizeHandleR"
		})
	}
	for i, handle in ipairs(handles) do
		local isResizing = false
		local startPos, startSize
		handle.MouseButton1Down:Connect(function(x,y)
			if self.Maximized then return end
			isResizing = true
			startPos = Vector2.new(x,y)
			startSize = self.Instance.Size
			_G.CensuraG.WindowManager:BringToFront(self)
			EventManager:FireEvent("WindowResizeStart", self)
		end)
		handle.MouseButton1Up:Connect(function()
			isResizing = false
			EventManager:FireEvent("WindowResizeEnd", self)
		end)
		handle.MouseMoved:Connect(function(x,y)
			if not isResizing then return end
			local delta = Vector2.new(x,y) - startPos
			local newSize = startSize
			if i == 1 then
				newSize = UDim2.new(0, math.max(startSize.X.Offset+delta.X, minWidth), 0, math.max(startSize.Y.Offset+delta.Y, minHeight))
			elseif i == 2 then
				newSize = UDim2.new(0, startSize.X.Offset, 0, math.max(startSize.Y.Offset+delta.Y, minHeight))
			elseif i == 3 then
				newSize = UDim2.new(0, math.max(startSize.X.Offset+delta.X, minWidth), 0, startSize.Y.Offset)
			end
			self.Instance.Size = newSize
			self.Shadow.Size = UDim2.new(0, newSize.X.Offset+10, 0, newSize.Y.Offset+10)
			EventManager:FireEvent("WindowResizing", self)
		end)
		handle.MouseEnter:Connect(function()
			if i == 1 then handle.Text = "⤡" elseif i == 2 then handle.Text = "↕" elseif i == 3 then handle.Text = "↔" end
		end)
		handle.MouseLeave:Connect(function() handle.Text = ""; isResizing = false end)
	end
	self.ResizeHandles = handles
	logger:debug("Made window resizable: %s", self.TitleText.Text)
	return self
end

function Window:SetModal(isModal)
	if isModal then
		_G.CensuraG.WindowManager:ShowModal(self)
	else
		_G.CensuraG.WindowManager:HideModal(self)
	end
	return self
end

function Window:SetTitle(title)
	if title then self.TitleText.Text = title end
	return self
end

function Window:AddElement(element)
	if not element or not element.Instance then
		logger:warn("Invalid element in AddElement")
		return self
	end
	element.Instance.Parent = self.ContentContainer
	element.Instance.ZIndex = self.ContentContainer.ZIndex + 1
	return self
end

function Window:Destroy()
	if self.DragHandler then self.DragHandler:Destroy() end
	if _G.CensuraG.WindowManager then _G.CensuraG.WindowManager:RemoveWindow(self) end
	if self.Minimized and _G.CensuraG.Taskbar then _G.CensuraG.Taskbar:RemoveWindow(self) end
	if self.Shadow then self.Shadow:Destroy() end
	if self.Instance then self.Instance:Destroy() end
	logger:info("Window destroyed: %s", self.TitleText and self.TitleText.Text or "Unknown")
	EventManager:FireEvent("WindowClosed", self)
end

return Window
