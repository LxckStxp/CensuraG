-- CensuraG/src/components/window.lua (fixed ScrollBarInset error)
local Config = _G.CensuraG.Config

return function(title)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = playerGui:FindFirstChild("ScreenGui") or Instance.new("ScreenGui", playerGui)
    screenGui.Name = "ScreenGui"

    -- Main Window Frame
    local Frame = Instance.new("Frame")
    Frame.Name = "WindowFrame"
    Frame.Size = UDim2.fromOffset(Config.Math.DefaultWindowSize.X, Config.Math.DefaultWindowSize.Y)
    Frame.Position = UDim2.fromOffset(100, 100)
    Frame.BackgroundColor3 = theme.PrimaryColor
    Frame.BackgroundTransparency = 0.15 -- Slight transparency
    Frame.BorderSizePixel = 0
    Frame.Parent = screenGui
    Frame.ClipsDescendants = true -- Clip content to window bounds

    -- Add corner radius
    local Corner = Instance.new("UICorner", Frame)
    Corner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)

    -- Add stroke for border
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = theme.BorderColor
    Stroke.Transparency = 0.6
    Stroke.Thickness = Config.Math.BorderThickness

    -- Title Bar
    local TitleBar = Instance.new("Frame", Frame)
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
    TitleBar.BackgroundColor3 = theme.SecondaryColor
    TitleBar.BackgroundTransparency = 0.8
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 2

    local TitleCorner = Instance.new("UICorner", TitleBar)
    TitleCorner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)

    local TitleStroke = Instance.new("UIStroke", TitleBar)
    TitleStroke.Color = theme.BorderColor
    TitleStroke.Transparency = 0.6
    TitleStroke.Thickness = Config.Math.BorderThickness

    local TitleText = Instance.new("TextLabel", TitleBar)
    TitleText.Name = "TitleText"
    TitleText.Size = UDim2.new(1, -100, 1, 0)  -- More space for buttons
    TitleText.Position = UDim2.new(0, 10, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = title
    TitleText.TextColor3 = theme.TextColor
    TitleText.Font = theme.Font
    TitleText.TextSize = theme.TextSize
    TitleText.TextWrapped = true
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.ZIndex = 2

    -- Window Control Buttons Container
    local ControlsFrame = Instance.new("Frame", TitleBar)
    ControlsFrame.Name = "WindowControls"
    ControlsFrame.Size = UDim2.new(0, 85, 1, -4)
    ControlsFrame.Position = UDim2.new(1, -87, 0, 2)
    ControlsFrame.BackgroundTransparency = 1
    ControlsFrame.ZIndex = 2

    local ControlsLayout = Instance.new("UIListLayout", ControlsFrame)
    ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
    ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    ControlsLayout.Padding = UDim.new(0, 2)

    -- Minimize Button
    local MinimizeButton = Instance.new("TextButton", ControlsFrame)
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, Config.Math.ButtonSize, 0, Config.Math.ButtonSize)
    MinimizeButton.BackgroundColor3 = theme.SecondaryColor
    MinimizeButton.BackgroundTransparency = 0.7
    MinimizeButton.Text = "−"
    MinimizeButton.TextColor3 = theme.TextColor
    MinimizeButton.Font = theme.Font
    MinimizeButton.TextSize = 14
    MinimizeButton.ZIndex = 3
    MinimizeButton.AutoButtonColor = false

    local MinimizeCorner = Instance.new("UICorner", MinimizeButton)
    MinimizeCorner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)

    -- Maximize Button
    local MaximizeButton = Instance.new("TextButton", ControlsFrame)
    MaximizeButton.Name = "MaximizeButton"
    MaximizeButton.Size = UDim2.new(0, Config.Math.ButtonSize, 0, Config.Math.ButtonSize)
    MaximizeButton.BackgroundColor3 = theme.SecondaryColor
    MaximizeButton.BackgroundTransparency = 0.7
    MaximizeButton.Text = "□"
    MaximizeButton.TextColor3 = theme.TextColor
    MaximizeButton.Font = theme.Font
    MaximizeButton.TextSize = 14
    MaximizeButton.ZIndex = 3
    MaximizeButton.AutoButtonColor = false

    local MaximizeCorner = Instance.new("UICorner", MaximizeButton)
    MaximizeCorner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)

    -- Close Button
    local CloseButton = Instance.new("TextButton", ControlsFrame)
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, Config.Math.ButtonSize, 0, Config.Math.ButtonSize)
    CloseButton.BackgroundColor3 = Color3.fromRGB(180, 70, 70)  -- Red close button
    CloseButton.BackgroundTransparency = 0.7
    CloseButton.Text = "×"
    CloseButton.TextColor3 = theme.TextColor
    CloseButton.Font = theme.Font
    CloseButton.TextSize = 16
    CloseButton.ZIndex = 3
    CloseButton.AutoButtonColor = false

    local CloseCorner = Instance.new("UICorner", CloseButton)
    CloseCorner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)

    -- Content Scrolling Frame - Simplified and fixed
    local ContentFrame = Instance.new("ScrollingFrame", Frame)
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Position = UDim2.new(0, 6, 0, 36)
    ContentFrame.Size = UDim2.new(1, -12, 1, -46) -- Leave room for resize handle
    ContentFrame.BackgroundColor3 = theme.PrimaryColor
    ContentFrame.BackgroundTransparency = 0.3
    ContentFrame.BorderSizePixel = 0
    ContentFrame.ScrollBarThickness = 6
    ContentFrame.ScrollBarImageColor3 = theme.AccentColor
    ContentFrame.ScrollBarImageTransparency = 0.3
    ContentFrame.CanvasSize = UDim2.new(0, 0, 2, 0) -- Start with larger canvas
    ContentFrame.ScrollingEnabled = true
    -- Remove problematic properties
    -- ContentFrame.ScrollBarInset = Enum.ScrollBarInset.ScrollBar
    -- ContentFrame.ElasticBehavior = Enum.ElasticBehavior.Always

    local ContentCorner = Instance.new("UICorner", ContentFrame)
    ContentCorner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)

    -- List layout for components
    local ListLayout = Instance.new("UIListLayout", ContentFrame)
    ListLayout.Padding = UDim.new(0, Config.Math.ElementSpacing)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

    -- Add padding
    local Padding = Instance.new("UIPadding", ContentFrame)
    Padding.PaddingTop = UDim.new(0, Config.Math.Padding)
    Padding.PaddingBottom = UDim.new(0, Config.Math.Padding)
    Padding.PaddingLeft = UDim.new(0, Config.Math.Padding)
    Padding.PaddingRight = UDim.new(0, Config.Math.Padding + 6) -- Extra padding for scrollbar

    -- Window State Management
    local WindowState = {
        current = Config.WindowStates.NORMAL,
        previousPosition = Frame.Position,
        previousSize = Frame.Size,
        isMaximized = false,
        isFocused = false,
        zIndex = 1
    }

    -- Resize handle (bottom-right corner)
    local ResizeHandle = Instance.new("TextButton", Frame)
    ResizeHandle.Name = "ResizeHandle"
    ResizeHandle.Size = UDim2.new(0, 16, 0, 16)
    ResizeHandle.Position = UDim2.new(1, -16, 1, -16)
    ResizeHandle.BackgroundColor3 = theme.AccentColor
    ResizeHandle.BackgroundTransparency = 0.7
    ResizeHandle.Text = "⤡"
    ResizeHandle.TextColor3 = theme.TextColor
    ResizeHandle.Font = theme.Font
    ResizeHandle.TextSize = 12
    ResizeHandle.ZIndex = 3
    ResizeHandle.AutoButtonColor = false

    local ResizeCorner = Instance.new("UICorner", ResizeHandle)
    ResizeCorner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)

    -- Focus Management
    local function bringToFront()
        if not WindowState.isFocused and _G.CensuraG.WindowManager then
            -- Find highest ZIndex among all windows
            local maxZIndex = 1
            if _G.CensuraG.Windows then
                for _, window in ipairs(_G.CensuraG.Windows) do
                    if window.Frame and window.Frame.ZIndex > maxZIndex then
                        maxZIndex = window.Frame.ZIndex
                    end
                end
            end
            
            -- Set this window to highest + 1
            Frame.ZIndex = maxZIndex + 1
            WindowState.zIndex = Frame.ZIndex
            WindowState.isFocused = true
            
            -- Visual focus feedback
            _G.CensuraG.AnimationManager:Tween(Stroke, {
                Color = theme.AccentColor,
                Transparency = 0.4
            }, Config.Animations.FocusAnimationSpeed)
            
            _G.CensuraG.Logger:info("Window focused: " .. title)
        end
    end

    -- Dragging functionality with focus
    local dragging = false
    local dragStartPos, frameStartPos

    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            bringToFront() -- Focus window when clicked
            dragging = true
            dragStartPos = input.Position
            frameStartPos = Frame.Position
            
            -- Store current state
            WindowState.previousPosition = Frame.Position
            
            -- Hover effect
            _G.CensuraG.AnimationManager:Tween(TitleStroke, {Transparency = 0.4}, 0.2)
            _G.CensuraG.AnimationManager:Tween(TitleBar, {BackgroundTransparency = 0.7}, 0.2)
        end
    end)

    TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            
            -- Check for window snapping if enabled
            if Config.Windows.EnableSnapping and WindowState.current == Config.WindowStates.NORMAL then
                local screenSize = game.Workspace.CurrentCamera.ViewportSize
                local windowPos = Frame.AbsolutePosition
                local snapDistance = Config.Math.SnapDistance
                
                -- Snap to left edge
                if windowPos.X < snapDistance then
                    WindowState.current = Config.WindowStates.SNAPPED_LEFT
                    _G.CensuraG.AnimationManager:Tween(Frame, {
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(0.5, 0, 1, -Config.Math.TaskbarHeight)
                    }, Config.Animations.WindowAnimationSpeed)
                -- Snap to right edge
                elseif windowPos.X + Frame.AbsoluteSize.X > screenSize.X - snapDistance then
                    WindowState.current = Config.WindowStates.SNAPPED_RIGHT
                    _G.CensuraG.AnimationManager:Tween(Frame, {
                        Position = UDim2.new(0.5, 0, 0, 0),
                        Size = UDim2.new(0.5, 0, 1, -Config.Math.TaskbarHeight)
                    }, Config.Animations.WindowAnimationSpeed)
                -- Snap to top (maximize)
                elseif windowPos.Y < snapDistance then
                    WindowState.isMaximized = true
                    WindowState.current = Config.WindowStates.MAXIMIZED
                    MaximizeButton.Text = "❐"
                    _G.CensuraG.AnimationManager:Tween(Frame, {
                        Position = UDim2.new(0, 0, 0, 0),
                        Size = UDim2.new(1, 0, 1, -Config.Math.TaskbarHeight)
                    }, Config.Animations.WindowAnimationSpeed)
                end
            end
            
            -- Return to normal visual state
            _G.CensuraG.AnimationManager:Tween(TitleStroke, {Transparency = 0.6}, 0.2)
            _G.CensuraG.AnimationManager:Tween(TitleBar, {BackgroundTransparency = 0.8}, 0.2)
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            -- If window is maximized or snapped, restore to normal first
            if WindowState.isMaximized or WindowState.current ~= Config.WindowStates.NORMAL then
                WindowState.isMaximized = false
                WindowState.current = Config.WindowStates.NORMAL
                MaximizeButton.Text = "□"
                
                -- Restore size and adjust position to follow cursor
                local cursorX = input.Position.X
                local screenSize = game.Workspace.CurrentCamera.ViewportSize
                local normalWidth = Config.Math.DefaultWindowSize.X
                local newX = math.max(0, math.min(screenSize.X - normalWidth, cursorX - normalWidth/2))
                
                Frame.Size = UDim2.fromOffset(normalWidth, Config.Math.DefaultWindowSize.Y)
                Frame.Position = UDim2.fromOffset(newX, 50)
                frameStartPos = Frame.Position
                dragStartPos = input.Position
            else
                local delta = input.Position - dragStartPos
                local newPos = UDim2.new(
                    frameStartPos.X.Scale,
                    frameStartPos.X.Offset + delta.X,
                    frameStartPos.Y.Scale,
                    frameStartPos.Y.Offset + delta.Y
                )
                _G.CensuraG.AnimationManager:Tween(Frame, {Position = newPos}, 0.05)
            end
        end
    end)

    -- Resizing functionality
    local resizing = false
    local resizeStartPos, frameStartSize

    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStartPos = input.Position
            frameStartSize = Frame.Size
            
            -- Hover effect
            _G.CensuraG.AnimationManager:Tween(ResizeHandle, {BackgroundTransparency = 0.5}, 0.2)
        end
    end)

    ResizeHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
            
            -- Return to normal
            _G.CensuraG.AnimationManager:Tween(ResizeHandle, {BackgroundTransparency = 0.7}, 0.2)
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStartPos
            local newSize = UDim2.new(
                frameStartSize.X.Scale,
                math.max(300, frameStartSize.X.Offset + delta.X),
                frameStartSize.Y.Scale,
                math.max(200, frameStartSize.Y.Offset + delta.Y)
            )
            _G.CensuraG.AnimationManager:Tween(Frame, {Size = newSize}, 0.05)
        end
    end)

    -- Hover effects for title bar
    TitleBar.MouseEnter:Connect(function()
        if not dragging then
            _G.CensuraG.AnimationManager:Tween(TitleStroke, {Transparency = 0.4}, 0.2)
            _G.CensuraG.AnimationManager:Tween(TitleBar, {BackgroundTransparency = 0.7}, 0.2)
        end
    end)

    TitleBar.MouseLeave:Connect(function()
        if not dragging then
            _G.CensuraG.AnimationManager:Tween(TitleStroke, {Transparency = 0.6}, 0.2)
            _G.CensuraG.AnimationManager:Tween(TitleBar, {BackgroundTransparency = 0.8}, 0.2)
        end
    end)

    -- Window Control Button Functionality
    
    -- Maximize Button Logic
    local function toggleMaximize()
        if WindowState.isMaximized then
            -- Restore window
            WindowState.isMaximized = false
            WindowState.current = Config.WindowStates.NORMAL
            MaximizeButton.Text = "□"
            
            _G.CensuraG.AnimationManager:Tween(Frame, {
                Position = WindowState.previousPosition,
                Size = WindowState.previousSize
            }, Config.Animations.WindowAnimationSpeed)
        else
            -- Maximize window
            WindowState.previousPosition = Frame.Position
            WindowState.previousSize = Frame.Size
            WindowState.isMaximized = true
            WindowState.current = Config.WindowStates.MAXIMIZED
            MaximizeButton.Text = "❐"
            
            _G.CensuraG.AnimationManager:Tween(Frame, {
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, 0, 1, -Config.Math.TaskbarHeight)
            }, Config.Animations.WindowAnimationSpeed)
        end
    end
    
    MaximizeButton.MouseButton1Click:Connect(toggleMaximize)
    
    -- Double-click title bar to maximize
    local lastTitleClick = 0
    TitleText.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local currentTime = tick()
            if currentTime - lastTitleClick < Config.Desktop.DoubleClickTime then
                toggleMaximize()
            end
            lastTitleClick = currentTime
        end
    end)
    
    -- Close Button Logic
    CloseButton.MouseButton1Click:Connect(function()
        if _G.CensuraG.WindowManager and _G.CensuraG.WindowManager.CloseWindow then
            _G.CensuraG.WindowManager:CloseWindow(title)
        else
            -- Fallback close behavior
            _G.CensuraG.AnimationManager:Tween(Frame, {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                BackgroundTransparency = 1
            }, Config.Animations.WindowAnimationSpeed)
            
            task.delay(Config.Animations.WindowAnimationSpeed, function()
                Frame:Destroy()
            end)
        end
    end)
    
    -- Button Hover Effects
    for _, button in pairs({MinimizeButton, MaximizeButton, CloseButton}) do
        button.MouseEnter:Connect(function()
            _G.CensuraG.AnimationManager:Tween(button, {BackgroundTransparency = 0.3}, 0.15)
        end)
        
        button.MouseLeave:Connect(function()
            _G.CensuraG.AnimationManager:Tween(button, {BackgroundTransparency = 0.7}, 0.15)
        end)
        
        button.MouseButton1Down:Connect(function()
            _G.CensuraG.AnimationManager:Tween(button, {BackgroundTransparency = 0.1}, 0.1)
        end)
        
        button.MouseButton1Up:Connect(function()
            _G.CensuraG.AnimationManager:Tween(button, {BackgroundTransparency = 0.3}, 0.1)
        end)
    end

    -- Resize handle hover effects
    ResizeHandle.MouseEnter:Connect(function()
        if not resizing then
            _G.CensuraG.AnimationManager:Tween(ResizeHandle, {BackgroundTransparency = 0.5}, 0.2)
        end
    end)

    ResizeHandle.MouseLeave:Connect(function()
        if not resizing then
            _G.CensuraG.AnimationManager:Tween(ResizeHandle, {BackgroundTransparency = 0.7}, 0.2)
        end
    end)

    -- Initialize animation
    Frame.BackgroundTransparency = 1
    _G.CensuraG.AnimationManager:Tween(Frame, {BackgroundTransparency = 0.15}, animConfig.FadeDuration)

    -- Update canvas size when children change
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        local contentHeight = ListLayout.AbsoluteContentSize.Y + Padding.PaddingTop.Offset + Padding.PaddingBottom.Offset
        ContentFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
    end)

    -- Force initial canvas size update after a short delay
    task.spawn(function()
        task.wait(0.5) -- Wait for content to be added
        local contentHeight = ListLayout.AbsoluteContentSize.Y + Padding.PaddingTop.Offset + Padding.PaddingBottom.Offset
        ContentFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(contentHeight, ContentFrame.AbsoluteSize.Y * 1.1))
    end)

    -- Window interface with enhanced functionality
    local Window = {
        Frame = Frame,
        TitleBar = TitleBar,
        TitleText = TitleText,
        MinimizeButton = MinimizeButton,
        MaximizeButton = MaximizeButton,
        CloseButton = CloseButton,
        ContentFrame = ContentFrame,
        ResizeHandle = ResizeHandle,
        State = WindowState,
        
        -- Window management methods
        AddComponent = function(self, component)
            if component and component.Instance then
                component.Instance.Parent = self.ContentFrame
                component.Instance.LayoutOrder = #self.ContentFrame:GetChildren() - 3
                _G.CensuraG.Logger:info("Added component to window")
                
                task.delay(0.1, function()
                    self:UpdateSize()
                end)
            else
                _G.CensuraG.Logger:warn("Invalid component provided to window")
            end
        end,
        
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("window", self)
        end,
        
        UpdateSize = function(self)
            local contentHeight = ListLayout.AbsoluteContentSize.Y + Padding.PaddingTop.Offset + Padding.PaddingBottom.Offset
            ContentFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(contentHeight, ContentFrame.AbsoluteSize.Y * 1.1))
        end,
        
        GetTitle = function(self)
            return title
        end,
        
        SetSize = function(self, width, height)
            if not WindowState.isMaximized then
                WindowState.previousSize = UDim2.new(0, width, 0, height)
                _G.CensuraG.AnimationManager:Tween(self.Frame, {
                    Size = UDim2.new(0, width, 0, height)
                }, Config.Animations.WindowAnimationSpeed)
                
                task.delay(Config.Animations.WindowAnimationSpeed, function()
                    self:UpdateSize()
                end)
            end
        end,
        
        -- New desktop functionality
        BringToFront = function(self)
            bringToFront()
        end,
        
        Maximize = function(self)
            if not WindowState.isMaximized then
                toggleMaximize()
            end
        end,
        
        Restore = function(self)
            if WindowState.isMaximized then
                toggleMaximize()
            elseif WindowState.current ~= Config.WindowStates.NORMAL then
                WindowState.current = Config.WindowStates.NORMAL
                _G.CensuraG.AnimationManager:Tween(Frame, {
                    Position = WindowState.previousPosition,
                    Size = WindowState.previousSize
                }, Config.Animations.WindowAnimationSpeed)
            end
        end,
        
        Close = function(self)
            CloseButton.MouseButton1Click:Fire()
        end,
        
        GetState = function(self)
            return WindowState.current
        end,
        
        IsMaximized = function(self)
            return WindowState.isMaximized
        end,
        
        IsFocused = function(self)
            return WindowState.isFocused
        end,
        
        SetFocused = function(self, focused)
            WindowState.isFocused = focused
            if not focused then
                _G.CensuraG.AnimationManager:Tween(Stroke, {
                    Transparency = 0.6
                }, Config.Animations.FocusAnimationSpeed)
            end
        end
    }

    _G.CensuraG.Logger:info("Window created: " .. title)
    return Window
end
