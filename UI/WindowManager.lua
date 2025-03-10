-- UI/WindowManager.lua: Enhanced window management system
local WindowManager = {}
local logger = _G.CensuraG.Logger
local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local EventManager = _G.CensuraG.EventManager

-- Initialize properties
WindowManager.Windows = {}
WindowManager.ZIndexCounter = 10 -- Start with a higher base ZIndex
WindowManager.WindowCount = 0
WindowManager.Grid = {
    columns = 2,
    spacing = 20,
    startX = 50,
    startY = 50
}
WindowManager.MaximizedWindow = nil

-- Initialize the window manager
function WindowManager:Init()
    logger:info("Initializing WindowManager with WindowCount: %d, ZIndexCounter: %d", 
        self.WindowCount, self.ZIndexCounter)
    
    -- Create a background frame for modal windows if needed
    self.ModalBackground = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.7,
        ZIndex = 5,
        Visible = false
    })
    
    -- Subscribe to screen size changes
    self:HandleScreenSizeChanges()
    
    logger:debug("WindowManager initialized")
    return self
end

-- Handle screen size changes
function WindowManager:HandleScreenSizeChanges()
    -- This would typically use GetPropertyChangedSignal for AbsoluteSize
    -- but we'll use a simpler approach for the HTTP version
    
    local function updateWindowPositions()
        local screenSize = Utilities.getScreenSize()
        
        -- Update grid settings based on screen size
        self.Grid.columns = screenSize.X > 1200 and 3 or 2
        
        -- Reposition windows that are off-screen
        for _, window in ipairs(self.Windows) do
            if window and window.Instance then
                local pos = window.Instance.Position
                local size = window.Instance.Size
                
                -- Check if window is off-screen
                if pos.X.Offset + size.X.Offset > screenSize.X or
                   pos.Y.Offset + size.Y.Offset > screenSize.Y then
                    
                    -- Reposition to be visible
                    local newX = math.min(pos.X.Offset, screenSize.X - size.X.Offset - 10)
                    local newY = math.min(pos.Y.Offset, screenSize.Y - size.Y.Offset - 10)
                    
                    window.Instance.Position = UDim2.new(0, newX, 0, newY)
                    logger:debug("Repositioned off-screen window: %s", window.Instance.Name)
                end
            end
        end
    end
    
    -- Initial update
    updateWindowPositions()
    
    -- Set up periodic checks (every 5 seconds)
    task.spawn(function()
        while task.wait(5) do
            if _G.CensuraG and _G.CensuraG.ScreenGui then
                updateWindowPositions()
            else
                break
            end
        end
    end)
end

-- Add a window to the manager
function WindowManager:AddWindow(window)
    if not window or not window.Instance then
        logger:warn("Invalid window instance in AddWindow")
        return
    end

    self.WindowCount = self.WindowCount + 1
    window.Instance.ZIndex = self.ZIndexCounter
    self.ZIndexCounter = self.ZIndexCounter + 1
    table.insert(self.Windows, window)
    
    -- Set window ID for tracking
    window.Id = window.Id or Utilities.generateId()
    
    logger:info("Added window: %s, WindowCount: %d, ZIndex: %d", 
        window.Instance.Name, self.WindowCount, window.Instance.ZIndex)

    -- Automatic grid positioning if window position is at origin
    if window.Instance.Position.X.Offset == 0 and window.Instance.Position.Y.Offset == 0 then
        self:PositionWindowInGrid(window)
    end
    
    -- Fire event for window added
    EventManager:FireEvent("WindowAdded", window)
    
    return window
end

-- Position a window in the grid layout
function WindowManager:PositionWindowInGrid(window)
    local screenSize = Utilities.getScreenSize()
    local windowWidth = window.Instance.Size.X.Offset
    local windowHeight = window.Instance.Size.Y.Offset
    local cols = self.Grid.columns
    local spacing = self.Grid.spacing
    
    -- Calculate position based on window count
    local index = self.WindowCount - 1
    local row = math.floor(index / cols)
    local col = index % cols
    
    local x = self.Grid.startX + col * (windowWidth + spacing)
    local y = self.Grid.startY + row * (windowHeight + spacing)
    
    -- Ensure window is on screen
    x = math.min(x, screenSize.X - windowWidth - 10)
    y = math.min(y, screenSize.Y - windowHeight - 10)
    
    window.Instance.Position = UDim2.new(0, x, 0, y)
    logger:debug("Positioned window %s in grid at (%d, %d)", window.Instance.Name, x, y)
end

-- Bring a window to the front
function WindowManager:BringToFront(window)
    if not window or not window.Instance then return end
    
    -- Find the window in our list
    local index = nil
    for i, w in ipairs(self.Windows) do
        if w == window then
            index = i
            break
        end
    end
    
    if index then
        -- Update Z-index
        window.Instance.ZIndex = self.ZIndexCounter
        self.ZIndexCounter = self.ZIndexCounter + 1
        
        -- Update children Z-indices
        for _, child in ipairs(window.Instance:GetChildren()) do
            if child:IsA("GuiObject") then
                child.ZIndex = window.Instance.ZIndex + 1
            end
        end
        
        -- Move to end of list (top of stack)
        table.remove(self.Windows, index)
        table.insert(self.Windows, window)
        
        logger:debug("Brought window to front: %s, New ZIndex: %d", 
            window.Instance.Name, window.Instance.ZIndex)
        
        -- Fire event
        EventManager:FireEvent("WindowFocused", window)
    end
end

-- Remove a window from the manager
function WindowManager:RemoveWindow(window)
    if not window then return false end
    
    for i, w in ipairs(self.Windows) do
        if w == window then
            table.remove(self.Windows, i)
            self.WindowCount = self.WindowCount - 1
            
            logger:info("Removed window: %s, WindowCount: %d", 
                window.Instance.Name, self.WindowCount)
            
            -- Fire event
            EventManager:FireEvent("WindowRemoved", window)
            return true
        end
    end
    
    logger:warn("Window not found for removal")
    return false
end

-- Maximize a window
function WindowManager:MaximizeWindow(window)
    if not window or not window.Instance then return false end
    
    -- Store the current state for restoration
    window.PreviousPosition = window.Instance.Position
    window.PreviousSize = window.Instance.Size
    
    -- Get screen dimensions
    local screenSize = Utilities.getScreenSize()
    
    -- Animate to full screen
    _G.CensuraG.Animation:Tween(window.Instance, {
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, screenSize.X, 0, screenSize.Y - 40) -- Leave space for taskbar
    }, 0.3)
    
    self.MaximizedWindow = window
    window.IsMaximized = true
    
    -- Bring to front
    self:BringToFront(window)
    
    logger:debug("Maximized window: %s", window.Instance.Name)
    EventManager:FireEvent("WindowMaximized", window)
    
    return true
end

-- Restore a maximized window
function WindowManager:RestoreWindow(window)
    if not window or not window.Instance or not window.IsMaximized then return false end
    
    if window.PreviousPosition and window.PreviousSize then
        -- Animate back to original size and position
        _G.CensuraG.Animation:Tween(window.Instance, {
            Position = window.PreviousPosition,
            Size = window.PreviousSize
        }, 0.3)
        
        window.IsMaximized = false
        
        if self.MaximizedWindow == window then
            self.MaximizedWindow = nil
        end
        
        logger:debug("Restored window: %s", window.Instance.Name)
        EventManager:FireEvent("WindowRestored", window)
        
        return true
    end
    
    return false
end

-- Toggle window maximize/restore
function WindowManager:ToggleMaximize(window)
    if not window or not window.Instance then return false end
    
    if window.IsMaximized then
        return self:RestoreWindow(window)
    else
        return self:MaximizeWindow(window)
    end
end

-- Show a window as modal (disabling interaction with other windows)
function WindowManager:ShowModal(window)
    if not window or not window.Instance then return false end
    
    -- Store current window state
    window.PreviousZIndex = window.Instance.ZIndex
    
    -- Show modal background
    if self.ModalBackground then
        self.ModalBackground.Visible = true
        self.ModalBackground.ZIndex = self.ZIndexCounter
        self.ZIndexCounter = self.ZIndexCounter + 1
    end
    
    -- Bring window above modal background
    window.Instance.ZIndex = self.ZIndexCounter
    self.ZIndexCounter = self.ZIndexCounter + 1
    
    -- Update children Z-indices
    for _, child in ipairs(window.Instance:GetChildren()) do
        if child:IsA("GuiObject") then
            child.ZIndex = window.Instance.ZIndex + 1
        end
    end
    
    window.IsModal = true
    
    logger:debug("Showed window as modal: %s", window.Instance.Name)
    EventManager:FireEvent("WindowModalShown", window)
    
    return true
end

-- Hide modal window
function WindowManager:HideModal(window)
    if not window or not window.Instance or not window.IsModal then return false end
    
    -- Hide modal background
    if self.ModalBackground then
        self.ModalBackground.Visible = false
    end
    
    -- Restore previous Z-index
    if window.PreviousZIndex then
        window.Instance.ZIndex = window.PreviousZIndex
        
        -- Update children Z-indices
        for _, child in ipairs(window.Instance:GetChildren()) do
            if child:IsA("GuiObject") then
                child.ZIndex = window.Instance.ZIndex + 1
            end
        end
    end
    
    window.IsModal = false
    
    logger:debug("Hidden modal window: %s", window.Instance.Name)
    EventManager:FireEvent("WindowModalHidden", window)
    
    return true
end

-- Arrange all windows in a grid
function WindowManager:ArrangeWindows()
    local screenSize = Utilities.getScreenSize()
    local cols = self.Grid.columns
    local spacing = self.Grid.spacing
    
    -- Calculate average window size
    local avgWidth, avgHeight = 300, 200
    local totalWindows = #self.Windows
    
    if totalWindows > 0 then
        local totalWidth, totalHeight = 0, 0
        for _, window in ipairs(self.Windows) do
            totalWidth = totalWidth + window.Instance.Size.X.Offset
            totalHeight = totalHeight + window.Instance.Size.Y.Offset
        end
        avgWidth = totalWidth / totalWindows
        avgHeight = totalHeight / totalWindows
    end
    
    -- Position each window
    for i, window in ipairs(self.Windows) do
        local index = i - 1
        local row = math.floor(index / cols)
        local col = index % cols
        
        local x = self.Grid.startX + col * (avgWidth + spacing)
        local y = self.Grid.startY + row * (avgHeight + spacing)
        
        -- Ensure window is on screen
        x = math.min(x, screenSize.X - avgWidth - 10)
        y = math.min(y, screenSize.Y - avgHeight - 10)
        
        -- Animate to new position
        _G.CensuraG.Animation:Tween(window.Instance, {
            Position = UDim2.new(0, x, 0, y)
        }, 0.3)
    end
    
    logger:info("Arranged %d windows in grid", #self.Windows)
    EventManager:FireEvent("WindowsArranged")
    
    return true
end

-- Minimize all windows
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

-- Restore all windows
function WindowManager:RestoreAllWindows()
    local count = 0
    for _, window in ipairs(self.Windows) do
        if window.Maximize and window.Minimized then
            window:Maximize()
            count = count + 1
        end
    end
    
    logger:info("Restored %d windows", count)
    return count
end

-- Close all windows
function WindowManager:CloseAllWindows()
    local count = #self.Windows
    
    -- Create a copy of the windows table to avoid iteration issues during removal
    local windowsCopy = {}
    for i, window in ipairs(self.Windows) do
        windowsCopy[i] = window
    end
    
    -- Close each window
    for _, window in ipairs(windowsCopy) do
        if window.Destroy then
            window:Destroy()
        end
    end
    
    self.Windows = {}
    self.WindowCount = 0
    
    logger:info("Closed %d windows", count)
    EventManager:FireEvent("AllWindowsClosed")
    
    return count
end

-- Clean up resources
function WindowManager:Destroy()
    self:CloseAllWindows()
    
    if self.ModalBackground then
        self.ModalBackground:Destroy()
        self.ModalBackground = nil
    end
    
    logger:info("WindowManager destroyed")
end

return WindowManager
            
