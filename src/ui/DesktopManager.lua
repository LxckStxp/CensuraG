-- CensuraG/src/ui/DesktopManager.lua (Desktop Shell Environment)
local DesktopManager = {}
DesktopManager.__index = DesktopManager

local Config = _G.CensuraG.Config
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

function DesktopManager:Initialize()
    self.Desktop = nil
    self.ContextMenu = nil
    self.Icons = {}
    
    self:CreateDesktop()
    self:SetupContextMenu()
    self:SetupGlobalInputHandling()
    
    _G.CensuraG.Logger:info("Desktop Manager initialized")
end

function DesktopManager:CreateDesktop()
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Create desktop background
    self.Desktop = Instance.new("Frame")
    self.Desktop.Name = "CensuraGDesktop"
    self.Desktop.Size = UDim2.new(1, 0, 1, 0)
    self.Desktop.Position = UDim2.new(0, 0, 0, 0)
    self.Desktop.BackgroundColor3 = Config.Desktop.BackgroundColor
    self.Desktop.BorderSizePixel = 0
    self.Desktop.ZIndex = -10 -- Behind everything
    self.Desktop.Parent = _G.CensuraG.ScreenGui or playerGui:FindFirstChild("CensuraGScreenGui")
    
    -- Add subtle gradient or pattern (optional)
    local Gradient = Instance.new("UIGradient", self.Desktop)
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Config.Desktop.BackgroundColor),
        ColorSequenceKeypoint.new(1, Color3.new(
            Config.Desktop.BackgroundColor.R * 0.8,
            Config.Desktop.BackgroundColor.G * 0.8,
            Config.Desktop.BackgroundColor.B * 0.8
        ))
    })
    Gradient.Rotation = 45
    
    -- Desktop icons container
    self.IconsContainer = Instance.new("Frame", self.Desktop)
    self.IconsContainer.Name = "DesktopIcons"
    self.IconsContainer.Size = UDim2.new(1, -20, 1, -Config.Math.TaskbarHeight - 20)
    self.IconsContainer.Position = UDim2.new(0, 10, 0, 10)
    self.IconsContainer.BackgroundTransparency = 1
    
    -- Grid layout for desktop icons
    local IconLayout = Instance.new("UIGridLayout", self.IconsContainer)
    IconLayout.CellSize = UDim2.new(0, Config.Desktop.IconSize + Config.Desktop.IconSpacing, 0, Config.Desktop.IconSize + 30)
    IconLayout.CellPadding = UDim2.new(0, Config.Desktop.IconSpacing, 0, Config.Desktop.IconSpacing)
    IconLayout.FillDirectionMaxCells = math.floor(self.IconsContainer.AbsoluteSize.X / (Config.Desktop.IconSize + Config.Desktop.IconSpacing))
    
    _G.CensuraG.Logger:info("Desktop background created")
end

function DesktopManager:SetupContextMenu()
    if not Config.Desktop.EnableContextMenu then return end
    
    -- Create context menu (initially hidden)
    self.ContextMenu = Instance.new("Frame")
    self.ContextMenu.Name = "DesktopContextMenu"
    self.ContextMenu.Size = UDim2.new(0, 180, 0, 120)
    self.ContextMenu.BackgroundColor3 = Config:GetTheme().SecondaryColor
    self.ContextMenu.BackgroundTransparency = 0.1
    self.ContextMenu.BorderSizePixel = 0
    self.ContextMenu.Visible = false
    self.ContextMenu.ZIndex = 1000 -- Very high to be above everything
    self.ContextMenu.Parent = _G.CensuraG.ScreenGui or game.Players.LocalPlayer.PlayerGui:FindFirstChild("CensuraGScreenGui")
    
    -- Add corner radius and stroke
    local MenuCorner = Instance.new("UICorner", self.ContextMenu)
    MenuCorner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)
    
    local MenuStroke = Instance.new("UIStroke", self.ContextMenu)
    MenuStroke.Color = Config:GetTheme().BorderColor
    MenuStroke.Transparency = 0.5
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

function DesktopManager:CreateDesktopIcon(name, iconId, callback)
    if not Config.Desktop.ShowDesktopIcons then return end
    
    local theme = Config:GetTheme()
    
    -- Icon container
    local IconFrame = Instance.new("Frame", self.IconsContainer)
    IconFrame.Size = UDim2.new(0, Config.Desktop.IconSize, 0, Config.Desktop.IconSize + 20)
    IconFrame.BackgroundTransparency = 1
    
    -- Icon image
    local IconImage = Instance.new("ImageLabel", IconFrame)
    IconImage.Size = UDim2.new(0, Config.Desktop.IconSize, 0, Config.Desktop.IconSize)
    IconImage.BackgroundTransparency = 1
    IconImage.Image = iconId or "rbxassetid://0"
    IconImage.ImageColor3 = theme.TextColor
    
    -- Icon label
    local IconLabel = Instance.new("TextLabel", IconFrame)
    IconLabel.Size = UDim2.new(1, 0, 0, 20)
    IconLabel.Position = UDim2.new(0, 0, 1, -20)
    IconLabel.BackgroundTransparency = 1
    IconLabel.Text = name
    IconLabel.TextColor3 = theme.TextColor
    IconLabel.TextSize = 10
    IconLabel.Font = theme.Font
    IconLabel.TextWrapped = true
    
    -- Double-click detection
    local lastClick = 0
    IconFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local currentTime = tick()
            if currentTime - lastClick < Config.Desktop.DoubleClickTime then
                if callback then callback() end
            end
            lastClick = currentTime
        end
    end)
    
    table.insert(self.Icons, {Frame = IconFrame, Name = name, Callback = callback})
    return IconFrame
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