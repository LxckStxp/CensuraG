-- CensuraG/src/ui/WindowManager.lua (Enhanced Desktop Window Manager)
local WindowManager = {}
WindowManager.__index = WindowManager

local Config = _G.CensuraG.Config

-- Class-level window management
WindowManager.ActiveWindow = nil
WindowManager.WindowStack = {}
WindowManager.NextZIndex = 100

function WindowManager.new(title)
    local self = setmetatable({}, WindowManager)
    
    -- Check window limits
    if _G.CensuraG.Windows and #_G.CensuraG.Windows >= Config.Windows.MaxOpenWindows then
        _G.CensuraG.Logger:warn("Maximum windows limit reached (" .. Config.Windows.MaxOpenWindows .. ")")
        return nil
    end
    
    -- Create the window using the component
    if not _G.CensuraG.Components or not _G.CensuraG.Components.window then
        _G.CensuraG.Logger:error("Window component not loaded properly")
        return nil
    end
    
    local windowComponent = _G.CensuraG.Components.window(title)
    if not windowComponent then
        _G.CensuraG.Logger:error("Failed to create window component")
        return nil
    end
    
    -- Store the entire window component
    self.Window = windowComponent
    
    -- For compatibility, store direct references to commonly used properties
    self.Frame = windowComponent.Frame
    self.TitleBar = windowComponent.TitleBar
    self.TitleText = windowComponent.TitleText
    self.MinimizeButton = windowComponent.MinimizeButton
    self.MaximizeButton = windowComponent.MaximizeButton
    self.CloseButton = windowComponent.CloseButton
    self.ContentFrame = windowComponent.ContentFrame
    
    -- Window state
    self.IsMinimized = false
    self.IsMaximized = false
    self.Title = title
    self.Id = #(_G.CensuraG.Windows or {}) + 1
    
    -- Set initial position based on config
    self:SetInitialPosition()
    
    -- Set initial Z-index and focus
    WindowManager.NextZIndex = WindowManager.NextZIndex + 1
    self.Frame.ZIndex = WindowManager.NextZIndex
    WindowManager.ActiveWindow = self
    
    -- Connect window control buttons
    if self.MinimizeButton then
        self.MinimizeButton.MouseButton1Click:Connect(function()
            self:ToggleMinimize()
        end)
    end
    
    if self.CloseButton then
        self.CloseButton.MouseButton1Click:Connect(function()
            self:Close()
        end)
    end
    
    -- Add to window stack
    table.insert(WindowManager.WindowStack, self)
    
    _G.CensuraG.Logger:info("Created window: " .. title .. " (ID: " .. self.Id .. ")")
    return self
end

function WindowManager:ToggleMinimize()
    self.IsMinimized = not self.IsMinimized
    
    if self.IsMinimized then
        -- Store the current position before minimizing
        self.OriginalPosition = self.Frame.Position
        self.OriginalSize = self.Frame.Size
        
        -- Find corresponding taskbar button position
        local targetButton = nil
        local targetPosition = UDim2.new(0.5, 0, 1, -Config.Math.TaskbarHeight / 2)
        
        if _G.CensuraG.Taskbar and _G.CensuraG.Taskbar.Instance then
            -- Find the taskbar button for this window
            local windowIndex = nil
            for i, window in ipairs(_G.CensuraG.Windows) do
                if window == self then
                    windowIndex = i
                    break
                end
            end
            
            if windowIndex then
                -- Find the corresponding button in the taskbar
                for _, button in ipairs(_G.CensuraG.Taskbar.Instance.Buttons or {}) do
                    if button:GetAttribute("WindowIndex") == windowIndex then
                        targetButton = button
                        break
                    end
                end
            end
        end
        
        if targetButton then
            -- Calculate the position of the button in screen space
            local buttonPos = targetButton.AbsolutePosition
            local buttonSize = targetButton.AbsoluteSize
            
            -- Calculate the center of the button in screen space
            local buttonCenterX = buttonPos.X + buttonSize.X / 2
            local buttonCenterY = buttonPos.Y + buttonSize.Y / 2
            
            -- Calculate the target position relative to the screen
            local screenSize = game.Workspace.CurrentCamera.ViewportSize
            targetPosition = UDim2.new(
                buttonCenterX / screenSize.X, 
                0, 
                buttonCenterY / screenSize.Y, 
                0
            )
            
            _G.CensuraG.Logger:info("Minimizing window to button position: " .. 
                tostring(targetPosition.X.Scale) .. ", " .. tostring(targetPosition.Y.Scale))
        else
            _G.CensuraG.Logger:warn("No taskbar button found for window, using default position")
        end
        
        -- Minimize animation - move to the taskbar button position
        _G.CensuraG.AnimationManager:Tween(self.Frame, {
            Position = targetPosition,
            Size = UDim2.new(0, self.Frame.AbsoluteSize.X * 0.1, 0, self.Frame.AbsoluteSize.Y * 0.1),
            BackgroundTransparency = 0.9
        }, Config.Animations.FadeDuration)
        
        -- Delay making invisible to allow animation to complete
        task.delay(Config.Animations.FadeDuration, function()
            if self.IsMinimized then -- Check if still minimized
                self.Frame.Visible = false
            end
        end)
    else
        -- Make visible first before animating
        self.Frame.Visible = true
        
        -- Restore animation
        _G.CensuraG.AnimationManager:Tween(self.Frame, {
            Position = self.OriginalPosition or UDim2.fromOffset(100, 100),
            Size = self.OriginalSize or UDim2.fromOffset(Config.Math.DefaultWindowSize.X, Config.Math.DefaultWindowSize.Y),
            BackgroundTransparency = 0.15
        }, Config.Animations.SlideDuration)
    end
    
    -- Update taskbar
    if _G.CensuraG.TaskbarManager and _G.CensuraG.TaskbarManager.UpdateTaskbar then
        _G.CensuraG.TaskbarManager:UpdateTaskbar()
    end
    
    _G.CensuraG.Logger:info("Window " .. (self.IsMinimized and "minimized" or "restored") .. ": " .. self.Title)
end

-- Window positioning
function WindowManager:SetInitialPosition()
    local position
    
    if Config.Windows.DefaultPosition == "cascade" then
        position = Config:GetCascadePosition(self.Id)
    elseif Config.Windows.DefaultPosition == "center" then
        local screenSize = game.Workspace.CurrentCamera.ViewportSize
        position = UDim2.new(
            0, (screenSize.X - Config.Math.DefaultWindowSize.X) / 2,
            0, (screenSize.Y - Config.Math.DefaultWindowSize.Y) / 2
        )
    else -- random
        local screenSize = game.Workspace.CurrentCamera.ViewportSize
        local maxX = screenSize.X - Config.Math.DefaultWindowSize.X
        local maxY = screenSize.Y - Config.Math.DefaultWindowSize.Y - Config.Math.TaskbarHeight
        position = UDim2.new(0, math.random(0, maxX), 0, math.random(50, maxY))
    end
    
    self.Frame.Position = position
end

-- Focus management
function WindowManager:BringToFront()
    if self.Window and self.Window.BringToFront then
        self.Window:BringToFront()
    end
    
    -- Update active window
    if WindowManager.ActiveWindow and WindowManager.ActiveWindow ~= self then
        WindowManager.ActiveWindow.Window:SetFocused(false)
    end
    
    WindowManager.ActiveWindow = self
    
    -- Update taskbar highlighting
    if _G.CensuraG.TaskbarManager and _G.CensuraG.TaskbarManager.UpdateActiveWindow then
        _G.CensuraG.TaskbarManager:UpdateActiveWindow(self)
    end
end

-- Window lifecycle management
function WindowManager:Close()
    -- Remove from windows list
    if _G.CensuraG.Windows then
        for i, window in ipairs(_G.CensuraG.Windows) do
            if window == self then
                table.remove(_G.CensuraG.Windows, i)
                break
            end
        end
    end
    
    -- Remove from window stack
    for i, window in ipairs(WindowManager.WindowStack) do
        if window == self then
            table.remove(WindowManager.WindowStack, i)
            break
        end
    end
    
    -- Update active window
    if WindowManager.ActiveWindow == self then
        WindowManager.ActiveWindow = WindowManager.WindowStack[#WindowManager.WindowStack]
        if WindowManager.ActiveWindow then
            WindowManager.ActiveWindow:BringToFront()
        end
    end
    
    -- Close animation
    if Config.Windows.EnableAnimations then
        _G.CensuraG.AnimationManager:Tween(self.Frame, {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundTransparency = 1
        }, Config.Animations.WindowAnimationSpeed)
        
        task.delay(Config.Animations.WindowAnimationSpeed, function()
            self.Frame:Destroy()
        end)
    else
        self.Frame:Destroy()
    end
    
    -- Update taskbar
    if _G.CensuraG.TaskbarManager and _G.CensuraG.TaskbarManager.UpdateTaskbar then
        _G.CensuraG.TaskbarManager:UpdateTaskbar()
    end
    
    _G.CensuraG.Logger:info("Closed window: " .. self.Title)
end

-- Window state management
function WindowManager:Maximize()
    if self.Window and self.Window.Maximize then
        self.Window:Maximize()
        self.IsMaximized = true
    end
end

function WindowManager:Restore()
    if self.Window and self.Window.Restore then
        self.Window:Restore()
        self.IsMaximized = false
    end
end

function WindowManager:GetState()
    if self.Window and self.Window.GetState then
        return self.Window:GetState()
    end
    return Config.WindowStates.NORMAL
end

-- Legacy methods for compatibility
function WindowManager:AddComponent(component)
    if self.Window and self.Window.AddComponent then
        self.Window:AddComponent(component)
    else
        _G.CensuraG.Logger:warn("Window component missing AddComponent method")
    end
end

function WindowManager:Refresh()
    if self.Window and self.Window.Refresh then
        self.Window:Refresh()
    end
    
    -- Also update the taskbar button for this window
    if _G.CensuraG.TaskbarManager and _G.CensuraG.TaskbarManager.UpdateTaskbar then
        _G.CensuraG.TaskbarManager:UpdateTaskbar()
    end
end

function WindowManager:GetTitle()
    return self.Title
end

function WindowManager:SetSize(width, height)
    if self.Window and self.Window.SetSize then
        self.Window:SetSize(width, height)
        _G.CensuraG.Logger:info("Set window size to " .. width .. "x" .. height .. " for: " .. self.Title)
    else
        _G.CensuraG.Logger:error("Failed to set size: Window component missing SetSize method")
    end
end

-- Class methods for window management
function WindowManager.GetActiveWindow()
    return WindowManager.ActiveWindow
end

function WindowManager.GetAllWindows()
    return WindowManager.WindowStack
end

function WindowManager.CloseAllWindows()
    for i = #WindowManager.WindowStack, 1, -1 do
        WindowManager.WindowStack[i]:Close()
    end
end

function WindowManager.TileWindows()
    local windows = WindowManager.WindowStack
    if #windows == 0 then return end
    
    local screenSize = game.Workspace.CurrentCamera.ViewportSize
    local rows = math.ceil(math.sqrt(#windows))
    local cols = math.ceil(#windows / rows)
    
    local windowWidth = screenSize.X / cols
    local windowHeight = (screenSize.Y - Config.Math.TaskbarHeight) / rows
    
    for i, window in ipairs(windows) do
        local row = math.floor((i - 1) / cols)
        local col = (i - 1) % cols
        
        window.Window:Restore() -- Restore from maximized state
        
        _G.CensuraG.AnimationManager:Tween(window.Frame, {
            Position = UDim2.new(0, col * windowWidth, 0, row * windowHeight),
            Size = UDim2.new(0, windowWidth - 4, 0, windowHeight - 4)
        }, Config.Animations.WindowAnimationSpeed)
    end
    
    _G.CensuraG.Logger:info("Tiled " .. #windows .. " windows")
end

function WindowManager.CascadeWindows()
    local windows = WindowManager.WindowStack
    if #windows == 0 then return end
    
    for i, window in ipairs(windows) do
        window.Window:Restore() -- Restore from maximized state
        
        local position = Config:GetCascadePosition(i)
        _G.CensuraG.AnimationManager:Tween(window.Frame, {
            Position = position,
            Size = UDim2.fromOffset(Config.Math.DefaultWindowSize.X, Config.Math.DefaultWindowSize.Y)
        }, Config.Animations.WindowAnimationSpeed)
    end
    
    _G.CensuraG.Logger:info("Cascaded " .. #windows .. " windows")
end

return WindowManager
