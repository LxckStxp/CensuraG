-- CensuraG/src/components/systemtray.lua (Enhanced Version with Error Fixed)
local Config = _G.CensuraG.Config
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

return function(parent)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    local localPlayer = Players.LocalPlayer
    
    -- Main System Tray Button
    local TrayFrame = Instance.new("Frame", parent)
    TrayFrame.Name = "SystemTray"
    TrayFrame.Size = UDim2.new(0, 160, 0, Config.Math.TaskbarHeight - 8)
    TrayFrame.Position = UDim2.new(1, -165, 0, 4)
    TrayFrame.BackgroundColor3 = theme.SecondaryColor
    TrayFrame.BackgroundTransparency = 0.6
    TrayFrame.BorderSizePixel = 0
    TrayFrame.ZIndex = 5
    TrayFrame.Active = true
    
    local TrayCorner = Instance.new("UICorner", TrayFrame)
    TrayCorner.CornerRadius = UDim.new(0, 4)
    
    local TrayStroke = Instance.new("UIStroke", TrayFrame)
    TrayStroke.Color = theme.AccentColor
    TrayStroke.Transparency = 0.7
    TrayStroke.Thickness = 1
    
    -- Avatar Image with Glow
    local AvatarImage = Instance.new("ImageLabel", TrayFrame)
    AvatarImage.Size = UDim2.new(0, 32, 0, 32)
    AvatarImage.Position = UDim2.new(0, 8, 0.5, -16)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.Image = Players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    AvatarImage.ZIndex = 6
    
    local AvatarCorner = Instance.new("UICorner", AvatarImage)
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    
    local AvatarGlow = Instance.new("UIStroke", AvatarImage)
    AvatarGlow.Color = theme.AccentColor
    AvatarGlow.Thickness = 2
    AvatarGlow.Transparency = 0.8
    
    -- Display Name with Shadow
    local DisplayName = Instance.new("TextLabel", TrayFrame)
    DisplayName.Size = UDim2.new(1, -48, 1, 0)
    DisplayName.Position = UDim2.new(0, 48, 0, 0)
    DisplayName.BackgroundTransparency = 1
    DisplayName.Text = localPlayer.DisplayName .. " (@" .. localPlayer.Name .. ")"
    DisplayName.TextColor3 = theme.TextColor
    DisplayName.Font = theme.Font
    DisplayName.TextSize = 13
    DisplayName.TextXAlignment = Enum.TextXAlignment.Left
    DisplayName.TextTruncate = Enum.TextTruncate.AtEnd
    DisplayName.ZIndex = 6
    
    local NameShadow = Instance.new("TextLabel", TrayFrame)
    NameShadow.Size = DisplayName.Size
    NameShadow.Position = UDim2.new(0, 49, 0, 1)
    NameShadow.BackgroundTransparency = 1
    NameShadow.Text = DisplayName.Text
    NameShadow.TextColor3 = Color3.new(0, 0, 0)
    NameShadow.TextTransparency = 0.7
    NameShadow.Font = theme.Font
    NameShadow.TextSize = 13
    NameShadow.TextXAlignment = Enum.TextXAlignment.Left
    NameShadow.TextTruncate = Enum.TextTruncate.AtEnd
    NameShadow.ZIndex = 5
    
    -- Server Info Panel with Shadow
    local Panel = Instance.new("Frame", TrayFrame)
    Panel.Name = "ServerInfoPanel"
    Panel.Size = UDim2.new(0, 220, 0, 160)
    Panel.Position = UDim2.new(1, -220, 0, -165) -- Start hidden above tray
    Panel.BackgroundColor3 = theme.PrimaryColor
    Panel.BackgroundTransparency = 0.1
    Panel.BorderSizePixel = 0
    Panel.Visible = false
    Panel.ZIndex = 10
    
    local PanelCorner = Instance.new("UICorner", Panel)
    PanelCorner.CornerRadius = UDim.new(0, 6)
    
    local PanelStroke = Instance.new("UIStroke", Panel)
    PanelStroke.Color = theme.AccentColor
    PanelStroke.Transparency = 0.5
    PanelStroke.Thickness = 1.5
    
    local PanelShadow = Instance.new("ImageLabel", Panel)
    PanelShadow.Size = UDim2.new(1, 10, 1, 10)
    PanelShadow.Position = UDim2.new(0, -5, 0, -5)
    PanelShadow.BackgroundTransparency = 1
    PanelShadow.Image = "rbxassetid://1316045217"
    PanelShadow.ImageColor3 = Color3.new(0, 0, 0)
    PanelShadow.ImageTransparency = 0.7
    PanelShadow.ScaleType = Enum.ScaleType.Slice
    PanelShadow.SliceCenter = Rect.new(10, 10, 10, 10)
    PanelShadow.ZIndex = 9
    
    -- Server Info Labels (Fixed version - no shadows to avoid errors)
    local playersLabel = Instance.new("TextLabel", Panel)
    playersLabel.Size = UDim2.new(1, -20, 0, 20)
    playersLabel.Position = UDim2.new(0, 10, 0, 10)
    playersLabel.BackgroundTransparency = 1
    playersLabel.Text = "Players: " .. #Players:GetPlayers() .. "/" .. game.Players.MaxPlayers
    playersLabel.TextColor3 = theme.TextColor
    playersLabel.Font = theme.Font
    playersLabel.TextSize = 12
    playersLabel.TextXAlignment = Enum.TextXAlignment.Left
    playersLabel.ZIndex = 11
    
    local gameNameLabel = Instance.new("TextLabel", Panel)
    gameNameLabel.Size = UDim2.new(1, -20, 0, 20)
    gameNameLabel.Position = UDim2.new(0, 10, 0, 35)
    gameNameLabel.BackgroundTransparency = 1
    gameNameLabel.Text = "Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    gameNameLabel.TextColor3 = theme.TextColor
    gameNameLabel.Font = theme.Font
    gameNameLabel.TextSize = 12
    gameNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    gameNameLabel.ZIndex = 11
    
    local gameIdLabel = Instance.new("TextLabel", Panel)
    gameIdLabel.Size = UDim2.new(1, -20, 0, 20)
    gameIdLabel.Position = UDim2.new(0, 10, 0, 60)
    gameIdLabel.BackgroundTransparency = 1
    gameIdLabel.Text = "Game ID: " .. game.PlaceId
    gameIdLabel.TextColor3 = theme.TextColor
    gameIdLabel.Font = theme.Font
    gameIdLabel.TextSize = 12
    gameIdLabel.TextXAlignment = Enum.TextXAlignment.Left
    gameIdLabel.ZIndex = 11
    
    local serverAgeLabel = Instance.new("TextLabel", Panel)
    serverAgeLabel.Size = UDim2.new(1, -20, 0, 20)
    serverAgeLabel.Position = UDim2.new(0, 10, 0, 85)
    serverAgeLabel.BackgroundTransparency = 1
    serverAgeLabel.Text = "Server Age: Calculating..."
    serverAgeLabel.TextColor3 = theme.TextColor
    serverAgeLabel.Font = theme.Font
    serverAgeLabel.TextSize = 12
    serverAgeLabel.TextXAlignment = Enum.TextXAlignment.Left
    serverAgeLabel.ZIndex = 11
    
    local serverIdLabel = Instance.new("TextLabel", Panel)
    serverIdLabel.Size = UDim2.new(1, -20, 0, 20)
    serverIdLabel.Position = UDim2.new(0, 10, 0, 110)
    serverIdLabel.BackgroundTransparency = 1
    serverIdLabel.Text = "Server ID: " .. game.JobId
    serverIdLabel.TextColor3 = theme.TextColor
    serverIdLabel.Font = theme.Font
    serverIdLabel.TextSize = 12
    serverIdLabel.TextXAlignment = Enum.TextXAlignment.Left
    serverIdLabel.ZIndex = 11
    
    -- Rejoin Button with Hover Effect
    local RejoinButton = Instance.new("TextButton", Panel)
    RejoinButton.Size = UDim2.new(0, 90, 0, 30)
    RejoinButton.Position = UDim2.new(0.5, -45, 1, -40)
    RejoinButton.BackgroundColor3 = theme.AccentColor
    RejoinButton.BackgroundTransparency = 0.6
    RejoinButton.Text = "Rejoin"
    RejoinButton.TextColor3 = theme.TextColor
    RejoinButton.Font = theme.Font
    RejoinButton.TextSize = 14
    RejoinButton.ZIndex = 11
    RejoinButton.Active = true
    
    local RejoinCorner = Instance.new("UICorner", RejoinButton)
    RejoinCorner.CornerRadius = UDim.new(0, 4)
    
    local RejoinStroke = Instance.new("UIStroke", RejoinButton)
    RejoinStroke.Color = theme.TextColor
    RejoinStroke.Transparency = 0.8
    RejoinStroke.Thickness = 1
    
    -- Hover Effects
    local function hoverEffect(obj, scaleUp)
        local targetTransparency = scaleUp and 0.4 or 0.6
        TweenService:Create(obj, TweenInfo.new(0.2), {BackgroundTransparency = targetTransparency}):Play()
        if obj == TrayFrame then
            TweenService:Create(TrayStroke, TweenInfo.new(0.2), {Transparency = scaleUp and 0.5 or 0.7}):Play()
        end
    end
    
    TrayFrame.MouseEnter:Connect(function()
        hoverEffect(TrayFrame, true)
    end)
    
    TrayFrame.MouseLeave:Connect(function()
        hoverEffect(TrayFrame, false)
    end)
    
    RejoinButton.MouseEnter:Connect(function()
        hoverEffect(RejoinButton, true)
    end)
    
    RejoinButton.MouseLeave:Connect(function()
        hoverEffect(RejoinButton, false)
    end)
    
    -- Panel Animation Setup
    local shownPos = UDim2.new(1, -220, 0, -165) -- Above tray
    local hiddenPos = UDim2.new(1, -220, 0, 0)   -- Below tray
    Panel.Position = hiddenPos -- Start hidden
    
    local isOpen = false
    TrayFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if not isOpen then
                -- Show panel with animation
                Panel.Visible = true
                TweenService:Create(Panel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = shownPos,
                    BackgroundTransparency = 0.1
                }):Play()
                isOpen = true
            else
                -- Hide panel with animation
                TweenService:Create(Panel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    Position = hiddenPos,
                    BackgroundTransparency = 0.1
                }):Play()
                task.delay(0.3, function()
                    Panel.Visible = false
                end)
                isOpen = false
            end
        end
    end)
    
    -- Rejoin Functionality
    RejoinButton.MouseButton1Click:Connect(function()
        TeleportService:Teleport(game.PlaceId, localPlayer)
    end)
    
    -- Dynamic Updates - Fixed to avoid errors
    local function updateInfo()
        pcall(function()
            -- Update player count
            playersLabel.Text = "Players: " .. #Players:GetPlayers() .. "/" .. game.Players.MaxPlayers
            
            -- Update server age
            local serverAge = math.floor((os.time() - (tonumber(game.JobId:match("^(%d+)") or os.time())) / 60))
            serverAgeLabel.Text = "Server Age: " .. serverAge .. " min"
        end)
    end
    
    -- Set up periodic updates
    local updateConnection = game:GetService("RunService").Heartbeat:Connect(updateInfo)
    
    -- SystemTray Object
    local SystemTray = {
        Instance = TrayFrame,
        Panel = Panel,
        Refresh = function(self)
            local theme = Config:GetTheme()
            TweenService:Create(self.Instance, TweenInfo.new(animConfig.FadeDuration), {BackgroundColor3 = theme.SecondaryColor, BackgroundTransparency = 0.6}):Play()
            TweenService:Create(TrayStroke, TweenInfo.new(animConfig.FadeDuration), {Color = theme.AccentColor}):Play()
            TweenService:Create(DisplayName, TweenInfo.new(animConfig.FadeDuration), {TextColor3 = theme.TextColor}):Play()
            DisplayName.Font = theme.Font
            NameShadow.Font = theme.Font
            
            TweenService:Create(self.Panel, TweenInfo.new(animConfig.FadeDuration), {BackgroundColor3 = theme.PrimaryColor}):Play()
            TweenService:Create(PanelStroke, TweenInfo.new(animConfig.FadeDuration), {Color = theme.AccentColor}):Play()
            
            -- Update all labels
            playersLabel.TextColor3 = theme.TextColor
            playersLabel.Font = theme.Font
            
            gameNameLabel.TextColor3 = theme.TextColor
            gameNameLabel.Font = theme.Font
            
            gameIdLabel.TextColor3 = theme.TextColor
            gameIdLabel.Font = theme.Font
            
            serverAgeLabel.TextColor3 = theme.TextColor
            serverAgeLabel.Font = theme.Font
            
            serverIdLabel.TextColor3 = theme.TextColor
            serverIdLabel.Font = theme.Font
            
            TweenService:Create(RejoinButton, TweenInfo.new(animConfig.FadeDuration), {BackgroundColor3 = theme.AccentColor, TextColor3 = theme.TextColor}):Play()
            RejoinButton.Font = theme.Font
        end,
        UpdateInfo = updateInfo,
        Cleanup = function()
            if updateConnection then
                updateConnection:Disconnect()
            end
        end
    }
    
    -- Initial update
    updateInfo()
    
    _G.CensuraG.Logger:info("Enhanced SystemTray created for " .. localPlayer.DisplayName)
    return SystemTray
end
