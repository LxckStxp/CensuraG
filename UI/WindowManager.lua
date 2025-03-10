-- UI/WindowManager.lua
-- Enhanced window management with improved structure and functionality

local WindowManager = {}
local logger = _G.CensuraG.Logger
local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager

WindowManager.Windows = {}
WindowManager.ZIndexCounter = 10
WindowManager.WindowCount = 0
WindowManager.Grid = { columns = 2, spacing = 20, startX = 50, startY = 50 }
WindowManager.MaximizedWindow = nil
WindowManager.FocusedWindow = nil
WindowManager.ModalWindow = nil

-- Private helper functions
local function updateZIndex(window, zIndex)
    if not window or not window.Instance then return end
    
    window.Instance.ZIndex = zIndex
    -- Update all children
    for _, child in ipairs(window.Instance:GetChildren()) do
        if child:IsA("GuiObject") then 
            child.ZIndex = zIndex + 1
            -- Update nested children
            for _, grandchild in ipairs(child:GetChildren()) do
                if grandchild:IsA("GuiObject") then
                    grandchild.ZIndex = zIndex + 2
                end
            end
        end
    end
end

local function getScreenSize()
    return Utilities.getScreenSize()
end

-- Main methods
function WindowManager:Init()
    logger:info("Initializing WindowManager with %d windows", self.WindowCount)
    
    -- Create modal background
    self.ModalBackground = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.7,
        ZIndex = 5,
        Visible = false,
        Name = "ModalBackground"
    })
    
    -- Add click handler to modal background
    self.ModalBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self.ModalWindow then
            Animation:ShakeEffect(self.ModalWindow.Instance, 3, 3)
        end
    end)
    
    -- Initialize screen size monitoring
    self:HandleScreenSizeChanges()
    
    -- Set up window focus event
    EventManager:SubscribeToEvent("WindowFocused", function(window)
        self.FocusedWindow = window
    end)
    
    logger:debug("WindowManager initialized")
    return self
end

function WindowManager:HandleScreenSizeChanges()
    local function updateWindows()
        local screenSize = getScreenSize()
        self.Grid.columns = screenSize.X > 1200 and 3 or 2
        
        for _, window in ipairs(self.Windows) do
            if window and window.Instance then
                local pos, size = window.Instance.Position, window.Instance.Size
                
                -- Check if window is off-screen
                if pos.X.Offset + size.X.Offset > screenSize.X or 
                   pos.Y.Offset + size.Y.Offset > screenSize.Y then
                    
                    local newX = math.min(pos.X.Offset, screenSize.X - size.X.Offset - 10)
                    local newY = math.min(pos.Y.Offset, screenSize.Y - size.Y.Offset - 10)
                    
                    window.Instance.Position = UDim2.new(0, newX, 0, newY)
                    logger:debug("Repositioned window: %s", window.Instance.Name)
                end
            end
        end
    end
    
    -- Initial update
    updateWindows()
    
    -- Schedule periodic updates
    task.spawn(function()
        while true do
            wait(5)
            pcall(updateWindows)
        end
    end)
end

function WindowManager:FindWindow(windowOrPredicate)
    local predicate = type(windowOrPredicate) == "function" 
        and windowOrPredicate 
        or function(w) return w == windowOrPredicate end
        
    for i, window in ipairs(self.Windows) do
        if predicate(window) then
            return window, i
        end
    end
    return nil, nil
end

function WindowManager:AddWindow(window)
    if not window or not window.Instance then
        logger:warn("Invalid window instance in AddWindow")
        return nil
    end
    
    -- Assign Z-index and increment counter
    window.Instance.ZIndex = self.ZIndexCounter
    self.ZIndexCounter = self.ZIndexCounter + 1
    
    -- Add window to collection
    table.insert(self.Windows, window)
    self.WindowCount = self.WindowCount + 1
    
    -- Ensure window has an ID
    window.Id = window.Id or Utilities.generateId()
    
    -- Position window if needed
    if window.Instance.Position.X.Offset == 0 and window.Instance.Position.Y.Offset == 0 then
        self:PositionWindowInGrid(window)
    end
    
    -- Make this the focused window
    self.FocusedWindow = window
    
    -- Fire event
    EventManager:FireEvent("WindowAdded", window)
    logger:info("Added window: %s; count: %d", window.Instance.Name, self.WindowCount)
    
    return window
end

function WindowManager:PositionWindowInGrid(window)
    if not window or not window.Instance then return end
    
    local screenSize = getScreenSize()
    local windowWidth = window.Instance.Size.X.Offset
    local windowHeight = window.Instance.Size.Y.Offset
    local cols = self.Grid.columns
    local spacing = self.Grid.spacing
    
    -- Calculate position based on current window count
    local index = self.WindowCount - 1
    local row = math.floor(index / cols)
    local col = index % cols
    
    -- Calculate coordinates
    local x = self.Grid.startX + col * (windowWidth + spacing)
    local y = self.Grid.startY + row * (windowHeight + spacing)
    
    -- Ensure window is on screen
    x = math.min(x, screenSize.X - windowWidth - 10)
    y = math.min(y, screenSize.Y - windowHeight - 10)
    
    -- Set position
    window.Instance.Position = UDim2.new(0, x, 0, y)
    logger:debug("Positioned window %s at (%d, %d)", window.Instance.Name, x, y)
end

function WindowManager:BringToFront(window)
    if not window or not window.Instance then return end
    
    local _, index = self:FindWindow(window)
    if not index then return end
    
    -- Update Z-index
    updateZIndex(window, self.ZIndexCounter)
    self.ZIndexCounter = self.ZIndexCounter + 1
    
    -- Move to end of array (top of visual stack)
    table.remove(self.Windows, index)
    table.insert(self.Windows, window)
    
    -- Set as focused window
    self.FocusedWindow = window
    
    logger:debug("Brought window to front: %s; new ZIndex: %d", window.Instance.Name, window.Instance.ZIndex)
    EventManager:FireEvent("WindowFocused", window)
    
    return window
end

function WindowManager:RemoveWindow(window)
    if not window then return false end
    
    local _, index = self:FindWindow(window)
    if not index then
        logger:warn("Window not found for removal")
        return false
    end
    
    -- Clean up taskbar button if exists
    if window.TaskbarButton then 
        window.TaskbarButton:Destroy() 
    end
    
    -- Remove from collection
    table.remove(self.Windows, index)
    self.WindowCount = self.WindowCount - 1
    
    -- Update focused window if needed
    if self.FocusedWindow == window then
        self.FocusedWindow = self.Windows[#self.Windows]
    end
    
    -- Update modal window if needed
    if self.ModalWindow == window then
        self.ModalWindow = nil
        self.ModalBackground.Visible = false
    end
    
    logger:info("Removed window: %s; count: %d", window.Instance.Name, self.WindowCount)
    EventManager:FireEvent("WindowRemoved", window)
    
    return true
end

function WindowManager:MaximizeWindow(window)
    if not window or not window.Instance then return false end
    
    -- Store original state for later restoration
    window.PreviousPosition = window.Instance.Position
    window.PreviousSize = window.Instance.Size
    
    -- Get screen dimensions
    local screenSize = getScreenSize()
    
    -- Animate to full screen
    Animation:Tween(window.Instance, { 
        Position = UDim2.new(0, 0, 0, 0), 
        Size = UDim2.new(0, screenSize.X, 0, screenSize.Y - 40) 
    }, 0.3)
    
    -- Update state
    self.MaximizedWindow = window
    window.IsMaximized = true
    
    -- Bring to front
    self:BringToFront(window)
    
    logger:debug("Maximized window: %s", window.Instance.Name)
    EventManager:FireEvent("WindowMaximized", window)
    
    return true
end

function WindowManager:RestoreWindow(window)
    if not window or not window.Instance or not window.IsMaximized then return false end
    if not window.PreviousPosition or not window.PreviousSize then return false end
    
    -- Animate back to original size/position
    Animation:Tween(window.Instance, { 
        Position = window.PreviousPosition, 
        Size = window.PreviousSize 
    }, 0.3)
    
    -- Update state
    window.IsMaximized = false
    if self.MaximizedWindow == window then 
        self.MaximizedWindow = nil 
    end
    
    logger:debug("Restored window: %s", window.Instance.Name)
    EventManager:FireEvent("WindowRestored", window)
    
    return true
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
    
    -- Store previous z-index
    window.PreviousZIndex = window.Instance.ZIndex
    
    -- Show modal background
    if self.ModalBackground then
        self.ModalBackground.Visible = true
        self.ModalBackground.ZIndex = self.ZIndexCounter
        self.ZIndexCounter = self.ZIndexCounter + 1
    end
    
    -- Set window above modal background
    updateZIndex(window, self.ZIndexCounter)
    self.ZIndexCounter = self.ZIndexCounter + 1
    
    -- Update state
    window.IsModal = true
    self.ModalWindow = window
    
    logger:debug("Window shown as modal: %s", window.Instance.Name)
    EventManager:FireEvent("WindowModalShown", window)
    
    return true
end

function WindowManager:HideModal(window)
    if not window or not window.Instance or not window.IsModal then return false end
    
    -- Hide modal background
    if self.ModalBackground then 
        self.ModalBackground.Visible = false 
    end
    
    -- Restore previous z-index
    if window.PreviousZIndex then
        updateZIndex(window, window.PreviousZIndex)
    end
    
    -- Update state
    window.IsModal = false
    if self.ModalWindow == window then
        self.ModalWindow = nil
    end
    
    logger:debug("Modal window hidden: %s", window.Instance.Name)
    EventManager:FireEvent("WindowModalHidden", window)
    
    return true
end

function WindowManager:ArrangeWindows()
    local screenSize = getScreenSize()
    local cols = self.Grid.columns
    local spacing = self.Grid.spacing
    local totalWindows = #self.Windows
    
    -- Calculate average window size
    local avgWidth, avgHeight = 300, 200
    if totalWindows > 0 then
        local totalW, totalH = 0, 0
        for _, window in ipairs(self.Windows) do
            totalW = totalW + window.Instance.Size.X.Offset
            totalH = totalH + window.Instance.Size.Y.Offset
        end
        avgWidth = totalW / totalWindows
        avgHeight = totalH / totalWindows
    end
    
    -- Arrange windows in grid
    for i, window in ipairs(self.Windows) do
        local index = i - 1
        local row = math.floor(index / cols)
        local col = index % cols
        
        -- Calculate coordinates
        local x = self.Grid.startX + col * (avgWidth + spacing)
        local y = self.Grid.startY + row * (avgHeight + spacing)
        
        -- Ensure window is on screen
        x = math.min(x, screenSize.X - avgWidth - 10)
        y = math.min(y, screenSize.Y - avgHeight - 10)
        
        -- Animate to position
        Animation:Tween(window.Instance, { Position = UDim2.new(0, x, 0, y) }, 0.3)
    end
    
    logger:info("Arranged %d windows in grid", totalWindows)
    EventManager:FireEvent("WindowsArranged")
    
    return true
end

function WindowManager:CascadeWindows()
    local screenSize = getScreenSize()
    local offset = 30
    local startX = 50
    local startY = 50
    
    for i, window in ipairs(self.Windows) do
        local x = startX + (i-1) * offset
        local y = startY + (i-1) * offset
        
        -- Ensure window is on screen
        x = math.min(x, screenSize.X - 300)
        y = math.min(y, screenSize.Y - 200)
        
        -- Animate to position
        Animation:Tween(window.Instance, { Position = UDim2.new(0, x, 0, y) }, 0.3)
    end
    
    logger:info("Cascaded %d windows", #self.Windows)
    EventManager:FireEvent("WindowsCascaded")
    
    return true
end

function WindowManager:MinimizeAllWindows()
    local count = 0
    for _, window in ipairs(self.Windows) do
        if window.Minimize and not window.Minimized then
            window:Minimize()
            count = count + 1
        end
    end
    
    logger:info("Minimized %d windows", count)
    return count
end

function WindowManager:RestoreAllWindows()
    local count = 0
    for _, window in ipairs(self.Windows) do
        if window.Restore and window.Minimized then
            window:Restore()
            count = count + 1
        end
    end
    
    logger:info("Restored %d windows", count)
    return count
end

function WindowManager:CloseAllWindows()
    local count = #self.Windows
    
    -- Create a copy to avoid issues during iteration
    local copy = {}
    for i, window in ipairs(self.Windows) do 
        copy[i] = window 
    end
    
    -- Close all windows
    for _, window in ipairs(copy) do
        if window.Destroy then 
            window:Destroy() 
        end
    end
    
    -- Clear state
    self.Windows = {}
    self.WindowCount = 0
    self.FocusedWindow = nil
    self.MaximizedWindow = nil
    self.ModalWindow = nil
    
    logger:info("Closed %d windows", count)
    EventManager:FireEvent("AllWindowsClosed")
    
    return count
end

function WindowManager:GetFocusedWindow()
    return self.FocusedWindow
end

function WindowManager:GetWindowById(id)
    return self:FindWindow(function(w) return w.Id == id end)
end

function WindowManager:GetWindowByTitle(title)
    return self:FindWindow(function(w) 
        return w.TitleText and w.TitleText.Text == title 
    end)
end

function WindowManager:GetWindowCount()
    return self.WindowCount
end

function WindowManager:IsWindowMaximized(window)
    return window and window.IsMaximized == true
end

function WindowManager:IsWindowMinimized(window)
    return window and window.Minimized == true
end

function WindowManager:IsWindowModal(window)
    return window and window.IsModal == true
end

function WindowManager:SetGridLayout(columns, spacing, startX, startY)
    self.Grid.columns = columns or self.Grid.columns
    self.Grid.spacing = spacing or self.Grid.spacing
    self.Grid.startX = startX or self.Grid.startX
    self.Grid.startY = startY or self.Grid.startY
    
    logger:debug("Window grid layout updated: columns=%d, spacing=%d", 
        self.Grid.columns, self.Grid.spacing)
        
    return self.Grid
end

function WindowManager:Destroy()
    -- Close all windows
    self:CloseAllWindows()
    
    -- Clean up modal background
    if self.ModalBackground then 
        self.ModalBackground:Destroy()
        self.ModalBackground = nil 
    end
    
    logger:info("WindowManager destroyed")
end

return WindowManager
