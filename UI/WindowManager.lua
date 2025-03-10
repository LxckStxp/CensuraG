-- UI/WindowManager.lua
-- Enhanced window management

local WindowManager = {}
local logger = _G.CensuraG.Logger
local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local EventManager = _G.CensuraG.EventManager

WindowManager.Windows = {}
WindowManager.ZIndexCounter = 10
WindowManager.WindowCount = 0
WindowManager.Grid = { columns = 2, spacing = 20, startX = 50, startY = 50 }
WindowManager.MaximizedWindow = nil

function WindowManager:Init()
	logger:info("Initializing WindowManager with %d windows", self.WindowCount)
	self.ModalBackground = Utilities.createInstance("Frame", {
		Parent = _G.CensuraG.ScreenGui,
		Size = UDim2.new(1,0,1,0),
		BackgroundColor3 = Color3.new(0,0,0),
		BackgroundTransparency = 0.7,
		ZIndex = 5,
		Visible = false
	})
	self:HandleScreenSizeChanges()
	logger:debug("WindowManager initialized")
	return self
end

function WindowManager:HandleScreenSizeChanges()
	local function updateWindows()
		local screenSize = Utilities.getScreenSize()
		self.Grid.columns = screenSize.X > 1200 and 3 or 2
		for _, window in ipairs(self.Windows) do
			if window and window.Instance then
				local pos, size = window.Instance.Position, window.Instance.Size
				if pos.X.Offset + size.X.Offset > screenSize.X or pos.Y.Offset + size.Y.Offset > screenSize.Y then
					local newX = math.min(pos.X.Offset, screenSize.X - size.X.Offset - 10)
					local newY = math.min(pos.Y.Offset, screenSize.Y - size.Y.Offset - 10)
					window.Instance.Position = UDim2.new(0, newX, 0, newY)
					logger:debug("Repositioned window: %s", window.Instance.Name)
				end
			end
		end
	end
	updateWindows()
	task.spawn(function() while wait(5) do updateWindows() end end)
end

function WindowManager:AddWindow(window)
	if not window or not window.Instance then
		logger:warn("Invalid window instance in AddWindow")
		return
	end
	self.WindowCount = self.WindowCount + 1
	window.Instance.ZIndex = self.ZIndexCounter
	self.ZIndexCounter = self.ZIndexCounter + 1
	table.insert(self.Windows, window)
	window.Id = window.Id or Utilities.generateId()
	logger:info("Added window: %s; count: %d", window.Instance.Name, self.WindowCount)
	if window.Instance.Position.X.Offset == 0 and window.Instance.Position.Y.Offset == 0 then
		self:PositionWindowInGrid(window)
	end
	EventManager:FireEvent("WindowAdded", window)
	return window
end

function WindowManager:PositionWindowInGrid(window)
	local screenSize = Utilities.getScreenSize()
	local windowWidth, windowHeight = window.Instance.Size.X.Offset, window.Instance.Size.Y.Offset
	local cols, spacing = self.Grid.columns, self.Grid.spacing
	local index = self.WindowCount - 1
	local row = math.floor(index/cols)
	local col = index % cols
	local x = self.Grid.startX + col * (windowWidth + spacing)
	local y = self.Grid.startY + row * (windowHeight + spacing)
	x = math.min(x, screenSize.X - windowWidth - 10)
	y = math.min(y, screenSize.Y - windowHeight - 10)
	window.Instance.Position = UDim2.new(0, x, 0, y)
	logger:debug("Positioned window %s at (%d, %d)", window.Instance.Name, x, y)
end

function WindowManager:BringToFront(window)
	if not window or not window.Instance then return end
	local idx
	for i, w in ipairs(self.Windows) do
		if w == window then idx = i; break end
	end
	if idx then
		window.Instance.ZIndex = self.ZIndexCounter
		self.ZIndexCounter = self.ZIndexCounter + 1
		for _, child in ipairs(window.Instance:GetChildren()) do
			if child:IsA("GuiObject") then child.ZIndex = window.Instance.ZIndex + 1 end
		end
		table.remove(self.Windows, idx)
		table.insert(self.Windows, window)
		logger:debug("Brought window to front: %s; new ZIndex: %d", window.Instance.Name, window.Instance.ZIndex)
		EventManager:FireEvent("WindowFocused", window)
	end
end

function WindowManager:RemoveWindow(window)
	if not window then return false end
	for i, w in ipairs(self.Windows) do
		if w == window then
			if window.TaskbarButton then window.TaskbarButton:Destroy() end
			table.remove(self.Windows, i)
			self.WindowCount = self.WindowCount - 1
			logger:info("Removed window: %s; count: %d", window.Instance.Name, self.WindowCount)
			EventManager:FireEvent("WindowRemoved", window)
			return true
		end
	end
	logger:warn("Window not found for removal")
	return false
end

function WindowManager:MaximizeWindow(window)
	if not window or not window.Instance then return false end
	window.PreviousPosition = window.Instance.Position
	window.PreviousSize = window.Instance.Size
	local screenSize = Utilities.getScreenSize()
	_G.CensuraG.Animation:Tween(window.Instance, { Position = UDim2.new(0,0,0,0), Size = UDim2.new(0, screenSize.X, 0, screenSize.Y-40) }, 0.3)
	self.MaximizedWindow = window
	window.IsMaximized = true
	self:BringToFront(window)
	logger:debug("Maximized window: %s", window.Instance.Name)
	EventManager:FireEvent("WindowMaximized", window)
	return true
end

function WindowManager:RestoreWindow(window)
	if not window or not window.Instance or not window.IsMaximized then return false end
	if window.PreviousPosition and window.PreviousSize then
		_G.CensuraG.Animation:Tween(window.Instance, { Position = window.PreviousPosition, Size = window.PreviousSize }, 0.3)
		window.IsMaximized = false
		if self.MaximizedWindow == window then self.MaximizedWindow = nil end
		logger:debug("Restored window: %s", window.Instance.Name)
		EventManager:FireEvent("WindowRestored", window)
		return true
	end
	return false
end

function WindowManager:ToggleMaximize(window)
	if not window or not window.Instance then return false end
	if window.IsMaximized then
		return self:RestoreWindow(window)
	else
		return self:MaximizeWindow(window)
	end
end

function WindowManager:ShowModal(window)
	if not window or not window.Instance then return false end
	window.PreviousZIndex = window.Instance.ZIndex
	if self.ModalBackground then
		self.ModalBackground.Visible = true
		self.ModalBackground.ZIndex = self.ZIndexCounter
		self.ZIndexCounter = self.ZIndexCounter + 1
	end
	window.Instance.ZIndex = self.ZIndexCounter
	self.ZIndexCounter = self.ZIndexCounter + 1
	for _, child in ipairs(window.Instance:GetChildren()) do
		if child:IsA("GuiObject") then child.ZIndex = window.Instance.ZIndex+1 end
	end
	window.IsModal = true
	logger:debug("Window shown as modal: %s", window.Instance.Name)
	EventManager:FireEvent("WindowModalShown", window)
	return true
end

function WindowManager:HideModal(window)
	if not window or not window.Instance or not window.IsModal then return false end
	if self.ModalBackground then self.ModalBackground.Visible = false end
	if window.PreviousZIndex then
		window.Instance.ZIndex = window.PreviousZIndex
		for _, child in ipairs(window.Instance:GetChildren()) do
			if child:IsA("GuiObject") then child.ZIndex = window.Instance.ZIndex+1 end
		end
	end
	window.IsModal = false
	logger:debug("Modal window hidden: %s", window.Instance.Name)
	EventManager:FireEvent("WindowModalHidden", window)
	return true
end

function WindowManager:ArrangeWindows()
	local screenSize = Utilities.getScreenSize()
	local cols = self.Grid.columns
	local spacing = self.Grid.spacing
	local totalWindows = #self.Windows
	local avgWidth, avgHeight = 300, 200
	if totalWindows > 0 then
		local totalW, totalH = 0, 0
		for _, window in ipairs(self.Windows) do
			totalW = totalW + window.Instance.Size.X.Offset
			totalH = totalH + window.Instance.Size.Y.Offset
		end
		avgWidth = totalW/totalWindows
		avgHeight = totalH/totalWindows
	end
	for i, window in ipairs(self.Windows) do
		local index = i - 1
		local row = math.floor(index/cols)
		local col = index % cols
		local x = self.Grid.startX + col*(avgWidth+spacing)
		local y = self.Grid.startY + row*(avgHeight+spacing)
		x = math.min(x, screenSize.X - avgWidth - 10)
		y = math.min(y, screenSize.Y - avgHeight - 10)
		_G.CensuraG.Animation:Tween(window.Instance, { Position = UDim2.new(0,x,0,y) }, 0.3)
	end
	logger:info("Arranged %d windows in grid", totalWindows)
	EventManager:FireEvent("WindowsArranged")
	return true
end

function WindowManager:MinimizeAllWindows()
	local count = 0
	for _, window in ipairs(self.Windows) do
		if window.Minimize and not window.Minimized then
			window:Minimize(); count = count + 1
		end
	end
	logger:info("Minimized %d windows", count)
	return count
end

function WindowManager:RestoreAllWindows()
	local count = 0
	for _, window in ipairs(self.Windows) do
		if window.Maximize and window.Minimized then
			window:Maximize(); count = count + 1
		end
	end
	logger:info("Restored %d windows", count)
	return count
end

function WindowManager:CloseAllWindows()
	local count = #self.Windows
	local copy = {}
	for i, window in ipairs(self.Windows) do copy[i] = window end
	for _, window in ipairs(copy) do
		if window.Destroy then window:Destroy() end
	end
	self.Windows = {}
	self.WindowCount = 0
	logger:info("Closed %d windows", count)
	EventManager:FireEvent("AllWindowsClosed")
	return count
end

function WindowManager:Destroy()
	self:CloseAllWindows()
	if self.ModalBackground then self.ModalBackground:Destroy(); self.ModalBackground = nil end
	logger:info("WindowManager destroyed")
end

return WindowManager
