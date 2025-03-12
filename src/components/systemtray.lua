-- CensuraG/src/components/systemtray.lua (Debugged and Simplified)
local Config = _G.CensuraG.Config
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

return function(parent)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations
    local localPlayer = Players.LocalPlayer
    
    -- Main System Tray Button
    local TrayFrame = Instance.new("Frame", parent)
    TrayFrame.Name = "SystemTray"
    TrayFrame.Size = UDim2.new(0, 150, 0, Config.Math.TaskbarHeight - 10)
    TrayFrame.Position = UDim2.new(1, -155, 0, 5)
    TrayFrame.BackgroundColor3 = theme.SecondaryColor
    TrayFrame.BackgroundTransparency = 0.7
    TrayFrame.BorderSizePixel = 0
    TrayFrame.ZIndex = 5 -- Ensure it’s above other taskbar elements
    TrayFrame.Active = true -- Make it clickable
    
    local TrayCorner = Instance.new("UICorner", TrayFrame)
    TrayCorner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)
    
    local TrayStroke = Instance.new("UIStroke", TrayFrame)
    TrayStroke.Color = theme.AccentColor
    TrayStroke.Transparency = 0.8
    TrayStroke.Thickness = Config.Math.BorderThickness
    
    -- Avatar Image
    local AvatarImage = Instance.new("ImageLabel", TrayFrame)
    AvatarImage.Size = UDim2.new(0, 30, 0, 30)
    AvatarImage.Position = UDim2.new(0, 5, 0.5, -15)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.Image = Players:GetUserThumbnailAsync(localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
    AvatarImage.ZIndex = 6
    
    local AvatarCorner = Instance.new("UICorner", AvatarImage)
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    
    -- Display Name
    local DisplayName = Instance.new("TextLabel", TrayFrame)
    DisplayName.Size = UDim2.new(1, -40, 1, 0)
    DisplayName.Position = UDim2.new(0, 40, 0, 0)
    DisplayName.BackgroundTransparency = 1
    DisplayName.Text = localPlayer.DisplayName .. " (@" .. localPlayer.Name .. ")"
    DisplayName.TextColor3 = theme.TextColor
    DisplayName.Font = theme.Font
    DisplayName.TextSize = 12
    DisplayName.TextXAlignment = Enum.TextXAlignment.Left
    DisplayName.TextTruncate = Enum.TextTruncate.AtEnd
    DisplayName.ZIndex = 6
    
    -- Server Info Panel
    local Panel = Instance.new("Frame", TrayFrame)
    Panel.Name = "ServerInfoPanel"
    Panel.Size = UDim2.new(0, 200, 0, 150)
    Panel.Position = UDim2.new(1, -200, 0, -155)
    Panel.BackgroundColor3 = theme.PrimaryColor
    Panel.BackgroundTransparency = 0.2
    Panel.BorderSizePixel = 0
    Panel.Visible = false
    Panel.ZIndex = 10
    
    local PanelCorner = Instance.new("UICorner", Panel)
    PanelCorner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)
    
    local PanelStroke = Instance.new("UIStroke", Panel)
    PanelStroke.Color = theme.AccentColor
    PanelStroke.Transparency = 0.6
    PanelStroke.Thickness = Config.Math.BorderThickness
    
    -- Server Info Labels
    local function createInfoLabel(name, value, yPos)
        local label = Instance.new("TextLabel", Panel)
        label.Size = UDim2.new(1, -10, 0, 20)
        label.Position = UDim2.new(0, 5, 0, yPos)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. tostring(value)
        label.TextColor3 = theme.TextColor
        label.Font = theme.Font
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 11
        return label
    end
    
    local gameInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    local serverAge = math.floor((os.time() - (tonumber(game.JobId:match("^(%d+)") or os.time())) / 60))
    
    local labels = {
        players = createInfoLabel("Players", #Players:GetPlayers() .. "/" .. game.Players.MaxPlayers, 5),
        gameName = createInfoLabel("Game", gameInfo.Name, 25),
        gameId = createInfoLabel("Game ID", game.PlaceId, 45),
        serverAge = createInfoLabel("Server Age", serverAge .. " min", 65),
        serverId = createInfoLabel("Server ID", game.JobId, 85)
    }
    
    -- Rejoin Button
    local RejoinButton = Instance.new("TextButton", Panel)
    RejoinButton.Size = UDim2.new(0, 80, 0, 25)
    RejoinButton.Position = UDim2.new(0.5, -40, 1, -30)
    RejoinButton.BackgroundColor3 = theme.AccentColor
    RejoinButton.BackgroundTransparency = 0.7
    RejoinButton.Text = "Rejoin"
    RejoinButton.TextColor3 = theme.TextColor
    RejoinButton.Font = theme.Font
    RejoinButton.TextSize = 12
    RejoinButton.ZIndex = 11
    RejoinButton.Active = true
    
    local RejoinCorner = Instance.new("UICorner", RejoinButton)
    RejoinCorner.CornerRadius = UDim.new(0, Config.Math.CornerRadius)
    
    -- Click Handler with Debugging
    TrayFrame.InputBegan:Connect(function(input)
        _G.CensuraG.Logger:info("SystemTray clicked, input type: " .. tostring(input.UserInputType))
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            _G.CensuraG.Logger:info("Toggling ServerInfoPanel, current visibility: " .. tostring(Panel.Visible))
            Panel.Visible = not Panel.Visible
            local targetTransparency = Panel.Visible and 0.2 or 1
            _G.CensuraG.AnimationManager:Tween(Panel, {BackgroundTransparency = targetTransparency}, 0.2)
            if not Panel.Visible then
                task.delay(0.2, function() Panel.Visible = false end)
            end
        end
    end)
    
    -- Hover Effects
    TrayFrame.MouseEnter:Connect(function()
        _G.CensuraG.AnimationManager:Tween(TrayFrame, {BackgroundTransparency = 0.5}, 0.2)
        _G.CensuraG.AnimationManager:Tween(TrayStroke, {Transparency = 0.6}, 0.2)
    end)
    
    TrayFrame.MouseLeave:Connect(function()
        _G.CensuraG.AnimationManager:Tween(TrayFrame, {BackgroundTransparency = 0.7}, 0.2)
        _G.CensuraG.AnimationManager:Tween(TrayStroke, {Transparency = 0.8}, 0.2)
    end)
    
    RejoinButton.MouseEnter:Connect(function()
        _G.CensuraG.AnimationManager:Tween(RejoinButton, {BackgroundTransparency = 0.5}, 0.2)
    end)
    
    RejoinButton.MouseLeave:Connect(function()
        _G.CensuraG.AnimationManager:Tween(RejoinButton, {BackgroundTransparency = 0.7}, 0.2)
    end)
    
    -- Rejoin Functionality
    RejoinButton.MouseButton1Click:Connect(function()
        _G.CensuraG.Logger:info("Rejoin button clicked")
        TeleportService:Teleport(game.PlaceId, localPlayer)
    end)
    
    -- Dynamic Updates
    local function updateInfo()
        local currentGameInfo = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        local currentServerAge = math.floor((os.time() - (tonumber(game.JobId:match("^(%d+)") or os.time())) / 60))
        
        labels.players.Text = "Players: " .. #Players:GetPlayers() .. "/" .. game.Players.MaxPlayers
        labels.gameName.Text = "Game: " .. currentGameInfo.Name
        labels.gameId.Text = "Game ID: " .. game.PlaceId
        labels.serverAge.Text = "Server Age: " .. currentServerAge .. " min"
        labels.serverId.Text = "Server ID: " .. game.JobId
    end
    
    game:GetService("RunService").Heartbeat:Connect(updateInfo)
    
    -- SystemTray Object
    local SystemTray = {
        Instance = TrayFrame,
        Panel = Panel,
        Refresh = function(self)
            local theme = Config:GetTheme()
            _G.CensuraG.AnimationManager:Tween(self.Instance, {BackgroundColor3 = theme.SecondaryColor, BackgroundTransparency = 0.7}, animConfig.FadeDuration)
            _G.CensuraG.AnimationManager:Tween(TrayStroke, {Color = theme.AccentColor})
            _G.CensuraG.AnimationManager:Tween(DisplayName, {TextColor3 = theme.TextColor})
            DisplayName.Font = theme.Font
            
            _G.CensuraG.AnimationManager:Tween(self.Panel, {BackgroundColor3 = theme.PrimaryColor})
            _G.CensuraG.AnimationManager:Tween(PanelStroke, {Color = theme.AccentColor})
            
            for _, label in pairs(labels) do
                _G.CensuraG.AnimationManager:Tween(label, {TextColor3 = theme.TextColor})
                label.Font = theme.Font
            end
            
            _G.CensuraG.AnimationManager:Tween(RejoinButton, {BackgroundColor3 = theme.AccentColor, TextColor3 = theme.TextColor})
            RejoinButton.Font = theme.Font
        end,
        UpdateInfo = updateInfo
    }
    
    _G.CensuraG.Logger:info("SystemTray created for " .. localPlayer.DisplayName)
    return SystemTray
end
