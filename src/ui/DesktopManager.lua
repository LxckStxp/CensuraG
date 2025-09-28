-- CensuraG/src/ui/DesktopManager.lua (Desktop Shell Environment)
local DesktopManager = {}
DesktopManager.__index = DesktopManager

local Config = _G.CensuraG.Config
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

function DesktopManager:Initialize()
    self.Desktop = nil
    self.StartMenu = nil
    self.ContextMenu = nil
    self.RegisteredApps = {}
    self.RecentApps = {}
    
    self:CreateDesktop()
    self:SetupStartMenu()
    self:SetupGlobalInputHandling()
    
    -- Register built-in apps
    self:RegisterBuiltInApps()
    
    _G.CensuraG.Logger:info("Desktop Manager initialized with glassmorphic design")
end

function DesktopManager:RegisterBuiltInApps()
    -- Register system apps
    self:RegisterApp(
        "Settings", 
        "System settings and preferences", 
        "rbxassetid://0", 
        function() self:OpenSettings() end, 
        "System"
    )
    
    self:RegisterApp(
        "Task Manager", 
        "View and manage running applications", 
        "rbxassetid://0", 
        function() self:OpenTaskManager() end, 
        "System"
    )
    
    _G.CensuraG.Logger:info("Built-in applications registered")
end

function DesktopManager:CreateDesktop()
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create transparent desktop overlay (no background - shows game world)
    self.Desktop = Instance.new("Frame")
    self.Desktop.Name = "CensuraGDesktop"
    self.Desktop.Size = UDim2.new(1, 0, 1, 0)
    self.Desktop.Position = UDim2.new(0, 0, 0, 0)
    self.Desktop.BackgroundTransparency = 1 -- Completely transparent
    self.Desktop.BorderSizePixel = 0
    self.Desktop.ZIndex = -5 -- Low but not lowest
    self.Desktop.Parent = _G.CensuraG.ScreenGui or playerGui:FindFirstChild("CensuraGScreenGui")
    
    -- No background or icons - we'll use start menu instead
    _G.CensuraG.Logger:info("Transparent desktop overlay created")
end

function DesktopManager:SetupStartMenu()
    local theme = Config:GetTheme()
    
    -- Create glassmorphic start menu (initially hidden)
    self.StartMenu = Instance.new("Frame")
    self.StartMenu.Name = "CensuraGStartMenu"
    self.StartMenu.Size = Config.StartMenu.Size
    self.StartMenu.Position = Config.StartMenu.Position
    self.StartMenu.BackgroundColor3 = theme.PrimaryColor
    self.StartMenu.BackgroundTransparency = theme.GlassTransparency
    self.StartMenu.BorderSizePixel = 0
    self.StartMenu.Visible = false
    self.StartMenu.ZIndex = 1000
    self.StartMenu.Parent = _G.CensuraG.ScreenGui or game.Players.LocalPlayer.PlayerGui:FindFirstChild("CensuraGScreenGui")
    
    -- Glassmorphic styling
    local MenuCorner = Instance.new("UICorner", self.StartMenu)
    MenuCorner.CornerRadius = UDim.new(0, 12)
    
    local MenuStroke = Instance.new("UIStroke", self.StartMenu)
    MenuStroke.Color = theme.BorderColor
    MenuStroke.Transparency = theme.BorderTransparency
    MenuStroke.Thickness = 1
    
    -- Blur effect background
    local BlurFrame = Instance.new("Frame", self.StartMenu)
    BlurFrame.Size = UDim2.new(1, 0, 1, 0)
    BlurFrame.BackgroundTransparency = 1
    BlurFrame.ZIndex = -1
    
    -- Create sections
    self:CreateStartMenuSections()
    
    -- Apps registry for start menu
    self.RegisteredApps = {}
    self.RecentApps = {}
    
    -- Create context menu for desktop
    self:CreateDesktopContextMenu()
end

function DesktopManager:CreateStartMenuSections()
    local theme = Config:GetTheme()
    
    -- Main scroll frame
    local ScrollFrame = Instance.new("ScrollingFrame", self.StartMenu)
    ScrollFrame.Size = UDim2.new(1, -20, 1, -20)
    ScrollFrame.Position = UDim2.new(0, 10, 0, 10)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.ScrollBarThickness = 4
    ScrollFrame.ScrollBarImageColor3 = theme.AccentColor
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local Layout = Instance.new("UIListLayout", ScrollFrame)
    Layout.Padding = UDim.new(0, 8)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Update canvas size when content changes
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 20)
    end)
    
    self.StartMenuContent = ScrollFrame
    self.StartMenuLayout = Layout
end

function DesktopManager:RefreshStartMenu()
    if not self.StartMenuContent then return end
    
    -- Clear existing content
    for _, child in pairs(self.StartMenuContent:GetChildren()) do
        if not child:IsA("UIListLayout") then
            child:Destroy()
        end
    end
    
    local theme = Config:GetTheme()
    local layoutOrder = 1
    
    -- Recent Apps Section
    if Config.StartMenu.ShowRecent and #self.RecentApps > 0 then
        self:CreateMenuSection("Recent", self.RecentApps, layoutOrder)
        layoutOrder = layoutOrder + 1
    end
    
    -- App Categories
    if Config.StartMenu.ShowCategories then
        for category, apps in pairs(self.RegisteredApps) do
            local appList = {}
            for _, app in pairs(apps) do
                table.insert(appList, app)
            end
            
            if #appList > 0 then
                self:CreateMenuSection(category, appList, layoutOrder)
                layoutOrder = layoutOrder + 1
            end
        end
    end
end

function DesktopManager:CreateMenuSection(title, apps, layoutOrder)
    local theme = Config:GetTheme()
    
    -- Section container
    local Section = Instance.new("Frame", self.StartMenuContent)
    Section.Size = UDim2.new(1, 0, 0, Config.StartMenu.CategoryHeight + (#apps * Config.StartMenu.ItemHeight))
    Section.BackgroundTransparency = 1
    Section.LayoutOrder = layoutOrder
    
    -- Section title
    local Title = Instance.new("TextLabel", Section)
    Title.Size = UDim2.new(1, 0, 0, Config.StartMenu.CategoryHeight)
    Title.BackgroundTransparency = 1
    Title.Text = title
    Title.TextColor3 = theme.SecondaryTextColor
    Title.TextSize = theme.TextSize - 1
    Title.Font = theme.BoldFont
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Apps container
    local AppsFrame = Instance.new("Frame", Section)
    AppsFrame.Size = UDim2.new(1, 0, 1, -Config.StartMenu.CategoryHeight)
    AppsFrame.Position = UDim2.new(0, 0, 0, Config.StartMenu.CategoryHeight)
    AppsFrame.BackgroundTransparency = 1
    
    local AppsLayout = Instance.new("UIListLayout", AppsFrame)
    AppsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Create app items
    for i, app in ipairs(apps) do
        self:CreateAppItem(app, AppsFrame, i)
    end
end

function DesktopManager:CreateAppItem(app, parent, layoutOrder)
    local theme = Config:GetTheme()
    
    -- App item button
    local AppButton = Instance.new("TextButton", parent)
    AppButton.Size = UDim2.new(1, 0, 0, Config.StartMenu.ItemHeight)
    AppButton.BackgroundColor3 = theme.SecondaryColor
    AppButton.BackgroundTransparency = 1
    AppButton.BorderSizePixel = 0
    AppButton.Text = ""
    AppButton.LayoutOrder = layoutOrder
    AppButton.AutoButtonColor = false
    
    local ButtonCorner = Instance.new("UICorner", AppButton)
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    
    -- App icon (placeholder)
    local Icon = Instance.new("Frame", AppButton)
    Icon.Size = UDim2.new(0, 24, 0, 24)
    Icon.Position = UDim2.new(0, 12, 0.5, -12)
    Icon.BackgroundColor3 = theme.AccentColor
    Icon.BackgroundTransparency = 0.8
    
    local IconCorner = Instance.new("UICorner", Icon)
    IconCorner.CornerRadius = UDim.new(0, 4)
    
    -- App name
    local Name = Instance.new("TextLabel", AppButton)
    Name.Size = UDim2.new(1, -50, 0.6, 0)
    Name.Position = UDim2.new(0, 45, 0, 0)
    Name.BackgroundTransparency = 1
    Name.Text = app.Name
    Name.TextColor3 = theme.TextColor
    Name.TextSize = theme.TextSize
    Name.Font = theme.Font
    Name.TextXAlignment = Enum.TextXAlignment.Left
    Name.TextYAlignment = Enum.TextYAlignment.Bottom
    
    -- App description
    local Description = Instance.new("TextLabel", AppButton)
    Description.Size = UDim2.new(1, -50, 0.4, 0)
    Description.Position = UDim2.new(0, 45, 0.6, 0)
    Description.BackgroundTransparency = 1
    Description.Text = app.Description
    Description.TextColor3 = theme.SecondaryTextColor
    Description.TextSize = theme.TextSize - 2
    Description.Font = theme.Font
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.TextYAlignment = Enum.TextYAlignment.Top
    
    -- Hover effects
    AppButton.MouseEnter:Connect(function()
        _G.CensuraG.AnimationManager:Tween(AppButton, {
            BackgroundTransparency = 0.9
        }, 0.15)
    end)
    
    AppButton.MouseLeave:Connect(function()
        _G.CensuraG.AnimationManager:Tween(AppButton, {
            BackgroundTransparency = 1
        }, 0.15)
    end)
    
    -- Click handler
    AppButton.MouseButton1Click:Connect(function()
        self:LaunchApp(app.Name, app.Category)
    end)
end

function DesktopManager:CreateDesktopContextMenu()
    if not Config.Desktop.EnableContextMenu then return end
    
    local theme = Config:GetTheme()
    
    -- Create context menu (initially hidden)
    self.ContextMenu = Instance.new("Frame")
    self.ContextMenu.Name = "DesktopContextMenu"
    self.ContextMenu.Size = UDim2.new(0, 180, 0, 120)
    self.ContextMenu.BackgroundColor3 = theme.PrimaryColor
    self.ContextMenu.BackgroundTransparency = theme.GlassTransparency
    self.ContextMenu.BorderSizePixel = 0
    self.ContextMenu.Visible = false
    self.ContextMenu.ZIndex = 1100
    self.ContextMenu.Parent = _G.CensuraG.ScreenGui or game.Players.LocalPlayer.PlayerGui:FindFirstChild("CensuraGScreenGui")
    
    -- Glassmorphic styling
    local MenuCorner = Instance.new("UICorner", self.ContextMenu)
    MenuCorner.CornerRadius = UDim.new(0, 8)
    
    local MenuStroke = Instance.new("UIStroke", self.ContextMenu)
    MenuStroke.Color = theme.BorderColor
    MenuStroke.Transparency = theme.BorderTransparency
    MenuStroke.Thickness = 1
    
    -- Menu items layout
    local MenuLayout = Instance.new("UIListLayout", self.ContextMenu)
    MenuLayout.Padding = UDim.new(0, 2)
    MenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Add menu items
    self:CreateContextMenuItem("Refresh Desktop", 1, function()
        self:RefreshDesktop()
    end)
    
    self:CreateContextMenuItem("New Folder", 2, function()
        _G.CensuraG.Logger:info("New Folder clicked (feature coming soon)")
    end, true) -- Separator after
    
    self:CreateContextMenuItem("Tile Windows", 3, function()
        _G.CensuraG.WindowManager.TileWindows()
    end)
    
    self:CreateContextMenuItem("Cascade Windows", 4, function()
        _G.CensuraG.WindowManager.CascadeWindows()
    end)
    
    self:CreateContextMenuItem("Close All Windows", 5, function()
        _G.CensuraG.WindowManager.CloseAllWindows()
    end, true) -- Separator after
    
    self:CreateContextMenuItem("Settings", 6, function()
        self:OpenSettings()
    end)
end

function DesktopManager:CreateContextMenuItem(text, layoutOrder, callback, addSeparator)
    local theme = Config:GetTheme()
    
    -- Menu item button
    local MenuItem = Instance.new("TextButton", self.ContextMenu)
    MenuItem.Size = UDim2.new(1, -6, 0, 24)
    MenuItem.Position = UDim2.new(0, 3, 0, 0)
    MenuItem.BackgroundColor3 = theme.SecondaryColor
    MenuItem.BackgroundTransparency = 1
    MenuItem.Text = text
    MenuItem.TextColor3 = theme.TextColor
    MenuItem.Font = theme.Font
    MenuItem.TextSize = 12
    MenuItem.TextXAlignment = Enum.TextXAlignment.Left
    MenuItem.LayoutOrder = layoutOrder
    MenuItem.AutoButtonColor = false
    
    -- Add padding
    local ItemPadding = Instance.new("UIPadding", MenuItem)
    ItemPadding.PaddingLeft = UDim.new(0, 8)
    
    -- Hover effects
    MenuItem.MouseEnter:Connect(function()
        _G.CensuraG.AnimationManager:Tween(MenuItem, {BackgroundTransparency = 0.8}, 0.1)
    end)
    
    MenuItem.MouseLeave:Connect(function()
        _G.CensuraG.AnimationManager:Tween(MenuItem, {BackgroundTransparency = 1}, 0.1)
    end)
    
    -- Click handler
    MenuItem.MouseButton1Click:Connect(function()
        self:HideContextMenu()
        if callback then
            callback()
        end
    end)
    
    -- Add separator if requested
    if addSeparator then
        local Separator = Instance.new("Frame", self.ContextMenu)
        Separator.Size = UDim2.new(1, -10, 0, 1)
        Separator.BackgroundColor3 = theme.BorderColor
        Separator.BackgroundTransparency = 0.7
        Separator.BorderSizePixel = 0
        Separator.LayoutOrder = layoutOrder + 0.5
    end
end

function DesktopManager:SetupGlobalInputHandling()
    -- Handle desktop right-clicks
    self.Desktop.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then -- Right click
            self:ShowContextMenu(input.Position)
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 then -- Left click
            self:HideContextMenu()
            -- Clear window focus if clicking on desktop
            if _G.CensuraG.WindowManager and _G.CensuraG.WindowManager.ActiveWindow then
                _G.CensuraG.WindowManager.ActiveWindow.Window:SetFocused(false)
                _G.CensuraG.WindowManager.ActiveWindow = nil
            end
        end
    end)
    
    -- Global input handling for window management
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        -- Hide context menu on any click outside it
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
            if self.ContextMenu and self.ContextMenu.Visible then
                local mousePos = UserInputService:GetMouseLocation()
                local menuPos = self.ContextMenu.AbsolutePosition
                local menuSize = self.ContextMenu.AbsoluteSize
                
                if mousePos.X < menuPos.X or mousePos.X > menuPos.X + menuSize.X or
                   mousePos.Y < menuPos.Y or mousePos.Y > menuPos.Y + menuSize.Y then
                    self:HideContextMenu()
                end
            end
        end
        
        -- Keyboard shortcuts
        if input.KeyCode == Enum.KeyCode.F5 then
            self:RefreshDesktop()
        elseif input.KeyCode == Enum.KeyCode.F4 and UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
            -- Alt+F4 to close active window
            if _G.CensuraG.WindowManager and _G.CensuraG.WindowManager.ActiveWindow then
                _G.CensuraG.WindowManager.ActiveWindow:Close()
            end
        end
    end)
end

function DesktopManager:ShowContextMenu(position)
    if not self.ContextMenu then return end
    
    self.ContextMenu.Position = UDim2.new(0, position.X, 0, position.Y)
    self.ContextMenu.Visible = true
    
    -- Ensure menu stays within screen bounds
    local screenSize = game.Workspace.CurrentCamera.ViewportSize
    local menuSize = self.ContextMenu.AbsoluteSize
    
    if position.X + menuSize.X > screenSize.X then
        self.ContextMenu.Position = UDim2.new(0, position.X - menuSize.X, 0, position.Y)
    end
    
    if position.Y + menuSize.Y > screenSize.Y then
        self.ContextMenu.Position = UDim2.new(0, self.ContextMenu.Position.X.Offset, 0, position.Y - menuSize.Y)
    end
    
    -- Fade in animation
    self.ContextMenu.BackgroundTransparency = 1
    _G.CensuraG.AnimationManager:Tween(self.ContextMenu, {BackgroundTransparency = 0.1}, 0.15)
end

function DesktopManager:HideContextMenu()
    if self.ContextMenu then
        self.ContextMenu.Visible = false
    end
end

function DesktopManager:RefreshDesktop()
    -- Refresh all windows and UI elements
    if _G.CensuraG.RefreshAll then
        _G.CensuraG.RefreshAll()
    end
    
    _G.CensuraG.Logger:info("Desktop refreshed")
end

function DesktopManager:OpenSettings()
    -- Create a settings window (placeholder for now)
    if _G.CensuraG.CreateWindow then
        local settingsWindow = _G.CensuraG.CreateWindow("CensuraG Settings")
        if settingsWindow and settingsWindow.Window then
            -- Add theme selector
            local themeDropdown = _G.CensuraG.Methods:CreateDropdown(
                settingsWindow.ContentFrame,
                "Theme",
                {"Military", "Cyberpunk"},
                function(selectedTheme)
                    _G.CensuraG.SetTheme(selectedTheme)
                end
            )
            
            -- Add window behavior toggles
            local enableSnapping = _G.CensuraG.Methods:CreateSwitch(
                settingsWindow.ContentFrame,
                "Enable Window Snapping",
                Config.Windows.EnableSnapping,
                function(enabled)
                    Config.Windows.EnableSnapping = enabled
                end
            )
            
            local enableAnimations = _G.CensuraG.Methods:CreateSwitch(
                settingsWindow.ContentFrame,
                "Enable Window Animations",
                Config.Windows.EnableAnimations,
                function(enabled)
                    Config.Windows.EnableAnimations = enabled
                end
            )
            
            settingsWindow.Window:AddComponent(themeDropdown)
            settingsWindow.Window:AddComponent(enableSnapping)
            settingsWindow.Window:AddComponent(enableAnimations)
        end
    end
end

-- Start Menu Management
function DesktopManager:RegisterApp(name, description, iconId, callback, category)
    category = category or "Applications"
    
    local appData = {
        Name = name,
        Description = description or "",
        Icon = iconId or "rbxassetid://0",
        Callback = callback,
        Category = category,
        LastUsed = 0
    }
    
    -- Add to registry
    if not self.RegisteredApps[category] then
        self.RegisteredApps[category] = {}
    end
    
    self.RegisteredApps[category][name] = appData
    
    -- Refresh start menu
    self:RefreshStartMenu()
    
    _G.CensuraG.Logger:info("Registered app: " .. name .. " in category: " .. category)
    return appData
end

function DesktopManager:LaunchApp(appName, category)
    local app = self.RegisteredApps[category] and self.RegisteredApps[category][appName]
    if not app then return false end
    
    -- Update recent apps
    app.LastUsed = tick()
    
    -- Add to recent if not already there
    local inRecent = false
    for i, recentApp in ipairs(self.RecentApps) do
        if recentApp.Name == appName then
            table.remove(self.RecentApps, i)
            inRecent = true
            break
        end
    end
    
    table.insert(self.RecentApps, 1, app)
    
    -- Limit recent apps
    if #self.RecentApps > Config.StartMenu.MaxRecentApps then
        table.remove(self.RecentApps)
    end
    
    -- Launch the app
    if app.Callback then
        app.Callback()
    end
    
    -- Hide start menu
    self:HideStartMenu()
    
    _G.CensuraG.Logger:info("Launched app: " .. appName)
    return true
end

function DesktopManager:ShowStartMenu()
    if not self.StartMenu then return end
    
    self.StartMenu.Visible = true
    
    -- Animate in
    self.StartMenu.Position = UDim2.new(
        Config.StartMenu.Position.X.Scale,
        Config.StartMenu.Position.X.Offset,
        1,
        50
    )
    
    _G.CensuraG.AnimationManager:Tween(self.StartMenu, {
        Position = Config.StartMenu.Position
    }, Config.StartMenu.AnimationSpeed)
    
    self:RefreshStartMenu()
end

function DesktopManager:HideStartMenu()
    if not self.StartMenu then return end
    
    _G.CensuraG.AnimationManager:Tween(self.StartMenu, {
        Position = UDim2.new(
            Config.StartMenu.Position.X.Scale,
            Config.StartMenu.Position.X.Offset,
            1,
            50
        )
    }, Config.StartMenu.AnimationSpeed)
    
    task.delay(Config.StartMenu.AnimationSpeed, function()
        if self.StartMenu then
            self.StartMenu.Visible = false
        end
    end)
end

function DesktopManager:ToggleStartMenu()
    if self.StartMenu.Visible then
        self:HideStartMenu()
    else
        self:ShowStartMenu()
    end
end

function DesktopManager:Refresh()
    if self.Desktop then
        local theme = Config:GetTheme()
        self.Desktop.BackgroundColor3 = Config.Desktop.BackgroundColor
        
        -- Refresh context menu
        if self.ContextMenu then
            _G.CensuraG.AnimationManager:Tween(self.ContextMenu, {
                BackgroundColor3 = theme.SecondaryColor
            }, Config.Animations.FadeDuration)
            
            -- Refresh menu items
            for _, child in pairs(self.ContextMenu:GetChildren()) do
                if child:IsA("TextButton") then
                    _G.CensuraG.AnimationManager:Tween(child, {
                        TextColor3 = theme.TextColor
                    }, Config.Animations.FadeDuration)
                    child.Font = theme.Font
                end
            end
        end
        
        -- Refresh desktop icons
        for _, icon in pairs(self.Icons) do
            for _, child in pairs(icon.Frame:GetChildren()) do
                if child:IsA("TextLabel") then
                    _G.CensuraG.AnimationManager:Tween(child, {
                        TextColor3 = theme.TextColor
                    }, Config.Animations.FadeDuration)
                    child.Font = theme.Font
                elseif child:IsA("ImageLabel") then
                    _G.CensuraG.AnimationManager:Tween(child, {
                        ImageColor3 = theme.TextColor
                    }, Config.Animations.FadeDuration)
                end
            end
        end
    end
end

return DesktopManager