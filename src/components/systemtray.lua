-- CensuraG/src/components/systemtray.lua (Fully Revised and Enhanced)
local Config = _G.CensuraG.Config
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

-- System Tray Component
return function(parent)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    local localPlayer = Players.LocalPlayer

    -- ### Main System Tray Button
    local TrayFrame = Instance.new("Frame")
    TrayFrame.Name = "SystemTray"
    TrayFrame.Size = UDim2.new(0, 160, 0, Config.Math.TaskbarHeight - 8)
    TrayFrame.Position = UDim2.new(1, -165, 0, 4)
    TrayFrame.BackgroundColor3 = theme.SecondaryColor
    TrayFrame.BackgroundTransparency = 0.6
    TrayFrame.BorderSizePixel = 0
    TrayFrame.ZIndex = 10 -- High ZIndex to ensure clickability
    TrayFrame.Active = true
    TrayFrame.Parent = parent

    local TrayCorner = Instance.new("UICorner")
    TrayCorner.CornerRadius = UDim.new(0, 4)
    TrayCorner.Parent = TrayFrame

    local TrayStroke = Instance.new("UIStroke")
    TrayStroke.Color = theme.AccentColor
    TrayStroke.Transparency = 0.7
    TrayStroke.Thickness = 1
    TrayStroke.Parent = TrayFrame

    -- Avatar Image
    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Size = UDim2.new(0, 32, 0, 32)
    AvatarImage.Position = UDim2.new(0, 8, 0.5, -16)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.Image = Players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    AvatarImage.ZIndex = 11
    AvatarImage.Parent = TrayFrame

    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = AvatarImage

    local AvatarGlow = Instance.new("UIStroke")
    AvatarGlow.Color = theme.AccentColor
    AvatarGlow.Thickness = 2
    AvatarGlow.Transparency = 0.8
    AvatarGlow.Parent = AvatarImage

    -- Display Name
    local DisplayName = Instance.new("TextLabel")
    DisplayName.Size = UDim2.new(1, -48, 1, 0)
    DisplayName.Position = UDim2.new(0, 48, 0, 0)
    DisplayName.BackgroundTransparency = 1
    DisplayName.Text = localPlayer.DisplayName .. " (@" .. localPlayer.Name .. ")"
    DisplayName.TextColor3 = theme.TextColor
    DisplayName.Font = theme.Font
    DisplayName.TextSize = 13
    DisplayName.TextXAlignment = Enum.TextXAlignment.Left
    DisplayName.TextTruncate = Enum.TextTruncate.AtEnd
    DisplayName.ZIndex = 11
    DisplayName.Parent = TrayFrame

    local NameShadow = Instance.new("TextLabel")
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
    NameShadow.ZIndex = 10
    NameShadow.Parent = TrayFrame

    -- ### Server Info Panel
    local Panel = Instance.new("Frame")
    Panel.Name = "ServerInfoPanel"
    Panel.Size = UDim2.new(0, 220, 0, 200)
    Panel.BackgroundColor3 = theme.PrimaryColor
    Panel.BackgroundTransparency = 1
    Panel.BorderSizePixel = 0
    Panel.ZIndex = 2 -- Behind taskbar elements
    Panel.Visible = false
    Panel.Parent = parent -- Parent to taskbar frame for correct positioning

    local PanelCorner = Instance.new("UICorner")
    PanelCorner.CornerRadius = UDim.new(0, 6)
    PanelCorner.Parent = Panel

    local PanelStroke = Instance.new("UIStroke")
    PanelStroke.Color = theme.AccentColor
    PanelStroke.Transparency = 0.5
    PanelStroke.Thickness = 1.5
    PanelStroke.ZIndex = 2
    PanelStroke.Parent = Panel

    local PanelShadow = Instance.new("ImageLabel")
    PanelShadow.Size = UDim2.new(1, 10, 1, 10)
    PanelShadow.Position = UDim2.new(0, -5, 0, -5)
    PanelShadow.BackgroundTransparency = 1
    PanelShadow.Image = "rbxassetid://1316045217"
    PanelShadow.ImageColor3 = Color3.new(0, 0, 0)
    PanelShadow.ImageTransparency = 0.7
    PanelShadow.ScaleType = Enum.ScaleType.Slice
    PanelShadow.SliceCenter = Rect.new(10, 10, 10, 10)
    PanelShadow.ZIndex = 1
    PanelShadow.Parent = Panel

    -- Server Info Labels
    local function createInfoLabel(name, value, yPos)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 20)
        label.Position = UDim2.new(0, 10, 0, yPos)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. tostring(value)
        label.TextColor3 = theme.TextColor
        label.Font = theme.Font
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 3
        label.Parent = Panel

        local shadow = Instance.new("TextLabel")
        shadow.Size = label.Size
        shadow.Position = UDim2.new(0, 11, 0, yPos + 1)
        shadow.BackgroundTransparency = 1
        shadow.Text = label.Text
        shadow.TextColor3 = Color3.new(0, 0, 0)
        shadow.TextTransparency = 0.7
        shadow.Font = theme.Font
        shadow.TextSize = 12
        shadow.TextXAlignment = Enum.TextXAlignment.Left
        shadow.ZIndex = 2
        shadow.Parent = Panel

        return {label = label, shadow = shadow}
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
    local RejoinButton = Instance.new("TextButton")
    RejoinButton.Size = UDim2.new(0, 90, 0, 30)
    RejoinButton.Position = UDim2.new(0.5, -45, 1, -45)
    RejoinButton.BackgroundColor3 = theme.AccentColor
    RejoinButton.BackgroundTransparency = 0.6
    RejoinButton.Text = "Rejoin"
    RejoinButton.TextColor3 = theme.TextColor
    RejoinButton.Font = theme.Font
    RejoinButton.TextSize = 14
    RejoinButton.ZIndex = 3
    RejoinButton.Active = true
    RejoinButton.Parent = Panel

    local RejoinCorner = Instance.new("UICorner")
    RejoinCorner.CornerRadius = UDim.new(0, 4)
    RejoinCorner.Parent = RejoinButton

    local RejoinStroke = Instance.new("UIStroke")
    RejoinStroke.Color = theme.TextColor
    RejoinStroke.Transparency = 0.8
    RejoinStroke.Thickness = 1
    RejoinStroke.ZIndex = 3
    RejoinStroke.Parent = RejoinButton

    -- ### Positioning and Animation Setup
    local panelHeight = Panel.Size.Y.Offset -- 200
    local trayHeight = Config.Math.TaskbarHeight -- e.g., 50
    local shownPos = UDim2.new(1, -220, 1, -panelHeight - trayHeight) -- Above taskbar
    local hiddenPos = UDim2.new(1, -220, 1, 0) -- Below taskbar
    Panel.Position = hiddenPos

    -- Toggle Panel with Animation
    local isOpen = false
    TrayFrame.InputBegan:Connect(function(input)
        print("SystemTray InputBegan:", input.UserInputType)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            print("Toggling panel, current isOpen:", isOpen)
            if not isOpen then
                -- Show panel
                Panel.Visible = true
                print("Panel set to visible")
                local success, err = pcall(function()
                    TweenService:Create(Panel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Position = shownPos,
                        BackgroundTransparency = 0.1
                    }):Play()
                end)
                if not success then
                    warn("Tween error when showing panel:", err)
                end
                isOpen = true
            else
                -- Hide panel
                local success, err = pcall(function()
                    TweenService:Create(Panel, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                        Position = hiddenPos,
                        BackgroundTransparency = 1
                    }):Play()
                end)
                if not success then
                    warn("Tween error when hiding panel:", err)
                end
                task.delay(0.3, function()
                    Panel.Visible = false
                    print("Panel hidden after animation")
                end)
                isOpen = false
            end
        end
    end)

    -- ### Hover Effects
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

    -- ### Rejoin Functionality
    RejoinButton.MouseButton1Click:Connect(function()
        TeleportService:Teleport(game.PlaceId, localPlayer)
    end)

    -- ### Dynamic Updates
    local function updateInfo()
        local currentGameInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        local currentServerAge = math.floor((os.time() - (tonumber(game.JobId:match("^(%d+)") or os.time())) / 60))

        labels.players.label.Text = "Players: " .. #Players:GetPlayers() .. "/" .. game.Players.MaxPlayers
        labels.gameName.label.Text = "Game: " .. currentGameInfo.Name
        labels.gameId.label.Text = "Game ID: " .. game.PlaceId
        labels.serverAge.label.Text = "Server Age: " .. currentServerAge .. " min"
        labels.serverId.label.Text = "Server ID: " .. game.JobId

        for _, labelPair in pairs(labels) do
            labelPair.shadow.Text = labelPair.label.Text
        end
    end

    game:GetService("RunService").Heartbeat:Connect(updateInfo)

    -- ### SystemTray Object
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
                TweenService:Create(labelPair.label, TweenInfo.new(animConfig.FadeDuration), {TextColor3 = theme.TextColor})
                labelPair.label.Font = theme.Font
                labelPair.shadow.Font = theme.Font
            end

            TweenService:Create(RejoinButton, TweenInfo.new(animConfig.FadeDuration), {BackgroundColor3 = theme.AccentColor, TextColor3 = theme.TextColor})
            RejoinButton.Font = theme.Font
        end,
        UpdateInfo = updateInfo
    }

    _G.CensuraG.Logger:info("Enhanced SystemTray created for " .. localPlayer.DisplayName)
    return SystemTray
end
