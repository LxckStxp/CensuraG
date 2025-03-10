-- UI/WindowManager.lua
-- Enhanced window management with ZIndexManager integration

local WindowManager = {}
local logger = _G.CensuraG.Logger
local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager

WindowManager.Windows = {}
WindowManager.WindowCount = 0
WindowManager.Grid = { columns = 2, spacing = 20, startX = 50, startY = 50 }
WindowManager.MaximizedWindow = nil
WindowManager.ModalWindow = nil -- Track the current modal window

function WindowManager:Init()
    logger:info("Initializing WindowManager with %d windows", self.WindowCount)
    if not _G.CensuraG.ScreenGui then
        logger:critical("ScreenGui not available, WindowManager initialization failed")
        return self
    end
    self.ModalBackground = Utilities.createInstance("Frame", {
        Parent = _G.CensuraG.ScreenGui,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 0.7,
        ZIndex = (_G.CensuraG.ZIndexManager and _G.CensuraG.ZIndexManager.BaseZIndex - 1) or 99, -- Fallback ZIndex
        Visible = false,
        Name = "ModalBackground"
    })
    if _G.CensuraG.ZIndexManager then
        _G.CensuraG.ZIndexManager:RegisterElement(self.ModalBackground)
    end
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
                    if Animation then
                        Animation:Tween(window.Instance, { Position = UDim2.new(0, newX, 0, newY) }, 0.2 / (_G.CensuraG.Config and _G.CensuraG.Config.AnimationSpeed or 1))
                    else
                        window.Instance.Position = UDim2.new(0, newX, 0, newY)
                    end
                    logger:debug("Repositioned window %s to (%d, %d)", window.Instance.Name, newX, newY)
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
        return nil
    end
    self.WindowCount = self.WindowCount + 1
    if _G.CensuraG.ZIndexManager then
        _G.CensuraG.ZIndexManager:RegisterElement(window.Instance)
    end
    table.insert(self.Windows, window)
    window.Id = window.Id or Utilities.generateId()
    if window.Instance.Position.X.Offset == 0 and window.Instance.Position.Y.Offset == 0 then
        self:PositionWindowInGrid(window)
    end
    logger:info("Added window: %s; count: %d", window.Instance.Name, self.WindowCount)
    EventManager:FireEvent("WindowAdded", window)
    return window
end

function WindowManager:PositionWindowInGrid(window)
    local screenSize = Utilities.getScreenSize()
    local windowWidth, windowHeight = window.Instance.Size.X.Offset, window.Instance.Size.Y.Offset
    local cols, spacing = self.Grid.columns, self.Grid.spacing
    local index = self.WindowCount - 1
    local row = math.floor(index / cols)
    local col = index % cols
    local x = self.Grid.startX + col * (windowWidth + spacing)
    local y = self.Grid.startY + row * (windowHeight + spacing)
    x = math.min(x, screenSize.X - windowWidth - 10)
    y = math.min(y, screenSize.Y - windowHeight - 10)
    window.Instance.Position = UDim2.new(0, x, 0, y)
    logger:debug("Positioned window %s at (%d, %d)", window.Instance.Name, x, y) -- Fixed 'problème'
end

function WindowManager:BringToFront(window)
    if not window or not window.Instance then
        logger:warn("Invalid window for BringToFront")
        return
    end
    for i, w in ipairs(self.Windows) do
        if w == window then
            table.remove(self.Windows, i)
            table.insert(self.Windows, window) -- Move to end (top of stack)
            if _G.CensuraG.ZIndexManager then
                _G.CensuraG.ZIndexManager:BringToFront(window.Instance)
            end
            logger:debug("Brought window to front: %s", window.Instance.Name)
            EventManager:FireEvent("WindowFocused", window)
            return
        end
    end
    logger:warn("Window %s not found in BringToFront", window.Instance.Name)
end

function WindowManager:SnapWindow(window)
    if not (_G.CensuraG.Config and _G.CensuraG.Config.WindowSnapEnabled) or not window or not window.Instance then return end
    local screenSize = Utilities.getScreenSize()
    local pos = window.Instance.Position
    local size = window.Instance.Size
    local snapThreshold = 20 -- Pixels near edge to snap
    
    local newX = pos.X.Offset
    local newY = pos.Y.Offset
    
    if newX < snapThreshold then
        newX = 0
    elseif newX + size.X.Offset > screenSize.X - snapThreshold then
        newX = screenSize.X - size.X.Offset
    end
    
    if newY < snapThreshold then
        newY = 0
    elseif newY + size.Y.Offset > screenSize.Y - snapThreshold - (_G.CensuraG.Taskbar and _G.CensuraG.Taskbar.Height or 0) then
        newY = screenSize.Y - size.Y.Offset - (_G.CensuraG.Taskbar and _G.CensuraG.Taskbar.Height or 0)
    end
    
    if newX ~= pos.X.Offset or newY ~= pos.Y.Offset then
        if Animation then
            Animation:Tween(window.Instance, { Position = UDim2.new(0, newX, 0, newY) }, 0.1 / (_G.CensuraG.Config and _G.CensuraG.Config.AnimationSpeed or 1))
        else
            window.Instance.Position = UDim2.new(0, newX, 0, newY)
        end
        logger:debug("Snapped window %s to (%d, %d)", window.Instance.Name, newX, newY)
    end
end

function WindowManager:RemoveWindow(window)
    if not window then return false end
    for i, w in ipairs(self.Windows) do
        if w == window then
            if window.TaskbarButton then window.TaskbarButton:Destroy() end
            table.remove(self.Windows, i)
            self.WindowCount = self.WindowCount - 1
            if self.MaximizedWindow == window then self.MaximizedWindow = nil end
            if self.ModalWindow == window then self.ModalWindow = nil end
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
    if window.IsMaximized then return false end
    window.PreviousPosition = window.Instance.Position
    window.PreviousSize = window.Instance.Size
    local screenSize = Utilities.getScreenSize()
    if Animation then
        Animation:Tween(window.Instance, {
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, screenSize.X, 0, screenSize.Y - (_G.CensuraG.Taskbar and _G.CensuraG.Taskbar.Height or 0))
        }, 0.3 / (_G.CensuraG.Config and _G.CensuraG.Config.AnimationSpeed or 1))
    else
        window.Instance.Position = UDim2.new(0, 0, 0, 0)
        window.Instance.Size = UDim2.new(0, screenSize.X, 0, screenSize.Y - (_G.CensuraG.Taskbar and _G.CensuraG.Taskbar.Height or 0))
    end
    self.MaximizedWindow = window
    window.IsMaximized = true
    self:BringToFront(window)
    logger:debug("Maximized window: %s", window.Instance.Name)
    EventManager:FireEvent("WindowMaximized", window)
    return true
end

function WindowManager:RestoreWindow(window)
    if not window or not window.Instance or not window.IsMaximized then return false end
    if not window.PreviousPosition or not window.PreviousSize then
        logger:warn("Cannot restore window %s: no previous state", window.Instance.Name)
        return false
    end
    if Animation then
        Animation:Tween(window.Instance, {
            Position = window.PreviousPosition,
            Size = window.PreviousSize
        }, 0.3 / (_G.CensuraG.Config and _G.CensuraG.Config.AnimationSpeed or 1))
    else
        window.Instance.Position = window.PreviousPosition
        window.Instance.Size = window.PreviousSize
    end
    window.IsMaximized = false
    if self.MaximizedWindow == window then self.MaximizedWindow = nil end
    logger:debug("Restored window: %s", window.Instance.Name)
    EventManager:FireEvent("WindowRestored", window)
    return true
end

function WindowManager:ToggleMaximize(window)
    if not window or not window.Instance then return false end
    return window.IsMaximized and self:RestoreWindow(window) or self:MaximizeWindow(window)
end

function WindowManager:ShowModal(window)
    if not window or not window.Instance then return false end
    if self.ModalWindow then
        logger:warn("Another modal window is already active: %s", self.ModalWindow.Instance.Name)
        return false
    end
    if _G.CensuraG.ZIndexManager then
        window.PreviousZIndex = _G.CensuraG.ZIndexManager:GetZIndex(window.Instance)
        self.ModalBackground.Visible = true
        _G.CensuraG.ZIndexManager:BringToFront(self.ModalBackground)
        _G.CensuraG.ZIndexManager:BringToFront(window.Instance)
    else
        logger:warn("ZIndexManager not available, modal functionality may be impaired")
        self.ModalBackground.Visible = true
    end
    self.ModalWindow = window
    window.IsModal = true
    logger:debug("Window shown as modal: %s", window.Instance.Name)
    EventManager:FireEvent("WindowModalShown", window)
    return true
end

function WindowManager:HideModal(window)
    if not window or not window.Instance or not window.IsModal or self.ModalWindow ~= window then return false end
    self.ModalBackground.Visible = false
    if _G.CensuraG.ZIndexManager and window.PreviousZIndex then
        _G.CensuraG.ZIndexManager:SetZIndex(window.Instance, window.PreviousZIndex)
    end
    self.ModalWindow = nil
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
    if totalWindows == 0 then return false end
    
    local avgWidth, avgHeight = 300, 200
    local totalW, totalH = 0, 0
    for _, window in ipairs(self.Windows) do
        totalW = totalW + window.Instance.Size.X.Offset
        totalH = totalH + window.Instance.Size.Y.Offset
    end
    avgWidth = totalW / totalWindows
    avgHeight = totalH / totalWindows
    
    for i, window in ipairs(self.Windows) do
        local index = i - 1
        local row = math.floor(index / cols)
        local col = index % cols
        local x = self.Grid.startX + col * (avgWidth + spacing)
        local y = self.Grid.startY + row * (avgHeight + spacing)
        x = math.min(x, screenSize.X - avgWidth - 10)
        y = math.min(y, screenSize.Y - avgHeight - (_G.CensuraG.Taskbar and _G.CensuraG.Taskbar.Height or 0) - 10)
        if Animation then
            Animation:Tween(window.Instance, { Position = UDim2.new(0, x, 0, y) }, 0.3 / (_G.CensuraG.Config and _G.CensuraG.Config.AnimationSpeed or 1))
        else
            window.Instance.Position = UDim2.new(0, x, 0, y)
        end
    end
    logger:info("Arranged %d windows in grid", totalWindows)
    EventManager:FireEvent("WindowsArranged")
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
    local copy = {}
    for i, window in ipairs(self.Windows) do copy[i] = window end
    for _, window in ipairs(copy) do
        if window.Destroy then window:Destroy() end
    end
    self.Windows = {}
    self.WindowCount = 0
    self.MaximizedWindow = nil
    self.ModalWindow = nil
    logger:info("Closed %d windows", count)
    EventManager:FireEvent("AllWindowsClosed")
    return count
end

function WindowManager:Destroy()
    self:CloseAllWindows()
    if self.ModalBackground then self.ModalBackground:Destroy() end
    logger:info("WindowManager destroyed")
end

return WindowManager
