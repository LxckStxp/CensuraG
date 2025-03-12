-- CensuraG/src/components/systemtray.lua (Fixed Overlap, Position, and Hover)
local Config = _G.CensuraG.Config
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
    
    -- Server Info Panel (Taller to Prevent Overlap)
    local Panel = Instance.new("Frame", TrayFrame)
    Panel.Name = "ServerInfoPanel"
    Panel.Size = UDim2.new(0, 220, 0, 200) -- Increased height from 160 to 200
    Panel.Position = UDim2.new(1, -220, 0, -210) -- Adjusted to stay above tray
    Panel.BackgroundColor3 = theme.PrimaryColor
    Panel.BackgroundTransparency = 1 -- Start fully transparent
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
    
    -- Server Info Labels with Adjusted Positions
    local function createInfoLabel(name, value, yPos)
        local label = Instance.new("TextLabel", Panel)
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0, 10, 0, yPos)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. tostring(value)
        label.TextColor3 = theme.TextColor
        label.Font = theme.Font
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 11
        
        local shadow = Instance.new("TextLabel", Panel)
        shadow.Size = label.Size
        shadow.Position = UDim2.new(0, 11, 0, yPos + 1)
        shadow.BackgroundTransparency = 1
        shadow.Text = label.Text
        shadow.TextColor3 = Color3.new(0, 0, 0)
        shadow.TextTransparency = 0.7
        shadow.Font = theme.Font
        shadow.TextSize = 12
        shadow.TextXAlignment = Enum.TextXAlignment.Left
        shadow.ZIndex = 10
        
        return label, shadow
    end
    
    local gameInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    local serverAge = math.floor((os.time() - (tonumber(game.JobId:match("^(%d+)") or os.time())) / 60))
    
    local labels = {
        players = createInfoLabel("Players", #Players:GetPlayers() .. "/" .. game.Players.MaxPlayers, 15),
        gameName = createInfoLabel("Game", gameInfo.Name, 45),
        gameId = createInfoLabel("Game ID", game.PlaceId, 75),
        serverAge = createInfoLabel("Server Age", serverAge .. " min", 105),
        serverId = createInfoLabel("Server ID", game.JobId, 135)
    }
    
    -- Rejoin Button
    local RejoinButton = Instance.new("TextButton", Panel)
    RejoinButton.Size = UDim2.new(0, 90, 0, 30)
    RejoinButton.Position = UDim2.new(0.5, -45, 1, -45)
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
    
    -- Close Button
    local CloseButton = Instance.new("TextButton", Panel)
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.Position = UDim2.new(1, -25, 0, 5)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "✖"
    CloseButton.TextColor3 = theme.TextColor
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.TextSize = 14
    CloseButton.ZIndex = 11
    
    CloseButton.MouseButton1Click:Connect(function()
        Panel.Visible = false
    end)
    
    -- Enhanced Hover Effects (No Position Shift)
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
    
    -- Toggle Panel with Animation
    local defaultPanelPos = UDim2.new(1, -220, 0, -210)
    local hiddenPanelPos = UDim2.new(1, -220, 0, 0) -- Hidden below tray
    
    TrayFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Panel.Visible = true
            if Panel.Position == hiddenPanelPos then
                -- Reset tray position and animate panel up
                TrayFrame.Position = UDim2.new(1, -165, 0, 4)
                TweenService:Create(Panel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = defaultPanelPos,
                    BackgroundTransparency = 0.1
                }):Play()
            else
                -- Animate panel down and hide
                TweenService:Create(Panel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                    Position = hiddenPanelPos,
                    BackgroundTransparency = 1
                }):Play()
                task.delay(0.3, function() Panel.Visible = false end)
            end
        end
    end)
    
    -- Initialize Panel Position
    Panel.Position = hiddenPanelPos
    
    -- Rejoin Functionality
    RejoinButton.MouseButton1Click:Connect(function()
        TeleportService:Teleport(game.PlaceId, localPlayer)
    end)
    
    -- Dynamic Updates
    local function updateInfo()
        local currentGameInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        local currentServerAge = math.floor((os.time() - (tonumber(game.JobId:match("^(%d+)") or os.time())) / 60))
        
        labels.players[1].Text = "Players: " .. #Players:GetPlayers() .. "/" .. game.Players.MaxPlayers
        labels.gameName[1].Text = "Game: " .. currentGameInfo.Name
        labels.gameId[1].Text = "Game ID: " .. game.PlaceId
        labels.serverAge[1].Text = "Server Age: " .. currentServerAge .. " min"
        labels.serverId[1].Text = "Server ID: " .. game.JobId
        
        for _, labelPair in pairs(labels) do
            labelPair[2].Text = labelPair[1].Text
        end
    end
    
    game:GetService("RunService").Heartbeat:Connect(updateInfo)
    
    -- SystemTray Object
    local SystemTray = {
        Instance = TrayFrame,
        Panel = Panel,
        Refresh = function(self)
            local theme = Config:GetTheme()
            TweenService:Create(self.Instance, TweenInfo.new(animConfig.FadeDuration), {BackgroundColor3 = theme.SecondaryColor, BackgroundTransparency = 0.6})
            TweenService:Create(TrayStroke, TweenInfo.new(animConfig.FadeDuration), {Color = theme.AccentColor})
            TweenService:Create(DisplayName, TweenInfo.new(animConfig.FadeDuration), {TextColor3 = theme.TextColor})
            DisplayName.Font = theme.Font
            NameShadow.Font = theme.Font
            
            TweenService:Create(self.Panel, TweenInfo.new(animConfig.FadeDuration), {BackgroundColor3 = theme.PrimaryColor})
            TweenService:Create(PanelStroke, TweenInfo.new(animConfig.FadeDuration), {Color = theme.AccentColor})
            
            for _, labelPair in pairs(labels) do
                TweenService:Create(labelPair[1], TweenInfo.new(animConfig.FadeDuration), {TextColor3 = theme.TextColor})
                labelPair[1].Font = theme.Font
                labelPair[2].Font = theme.Font
            end
            
            TweenService:Create(RejoinButton, TweenInfo.new(animConfig.FadeDuration), {BackgroundColor3 = theme.AccentColor, TextColor3 = theme.TextColor})
            RejoinButton.Font = theme.Font
            TweenService:Create(CloseButton, TweenInfo.new(animConfig.FadeDuration), {TextColor3 = theme.TextColor})
        end,
        UpdateInfo = updateInfo
    }
    
    _G.CensuraG.Logger:info("Enhanced SystemTray created for " .. localPlayer.DisplayName)
    return SystemTray
end
