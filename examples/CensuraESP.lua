--[[
    CensuraG ESP Application Example
    
    This ESP demonstrates the full capabilities of the CensuraG desktop environment:
    - Multiple windows with proper desktop behavior
    - Settings panel with all UI components
    - Real-time ESP functionality
    - Desktop integration and window management
    
    Features:
    - Player ESP with customizable colors and options
    - Distance display and health bars
    - Tracers and highlight effects
    - Comprehensive settings window
    - Statistics window
    - About window with system info
    
    Created for CensuraG Desktop Environment Test
--]]

-- Load CensuraG from GitHub
local CensuraG = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/CensuraG/main/CensuraG.lua", true))()

if not CensuraG then
    error("Failed to load CensuraG library")
end

-- Wait for full initialization
wait(3)

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ESP Configuration
local ESPConfig = {
    Enabled = true,
    ShowPlayers = true,
    ShowDistance = true,
    ShowHealth = true,
    ShowTracers = false,
    ShowHighlights = true,
    MaxDistance = 1000,
    
    -- Colors
    PlayerColor = Color3.fromRGB(0, 255, 0),
    EnemyColor = Color3.fromRGB(255, 0, 0),
    TracerColor = Color3.fromRGB(255, 255, 255),
    HealthBarColor = Color3.fromRGB(0, 255, 0),
    
    -- Visual Settings
    TextSize = 14,
    TracerThickness = 2,
    HighlightTransparency = 0.5,
    UpdateRate = 0.1 -- Update every 0.1 seconds
}

-- ESP Storage
local ESPObjects = {}
local ESPConnections = {}
local Statistics = {
    PlayersTracked = 0,
    TotalUpdates = 0,
    StartTime = tick(),
    LastUpdate = tick()
}

-- ESP Functions
local function createESPForPlayer(player)
    if player == LocalPlayer then return end
    
    local espData = {
        Player = player,
        BillboardGui = nil,
        Highlight = nil,
        Tracer = nil,
        NameLabel = nil,
        DistanceLabel = nil,
        HealthBar = nil
    }
    
    -- Create Billboard GUI
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ESP_" .. player.Name
    billboardGui.Size = UDim2.new(0, 200, 0, 100)
    billboardGui.StudsOffset = Vector3.new(0, 3, 0)
    billboardGui.AlwaysOnTop = true
    
    -- Main Frame
    local mainFrame = Instance.new("Frame", billboardGui)
    mainFrame.Size = UDim2.new(1, 0, 1, 0)
    mainFrame.BackgroundTransparency = 0.8
    mainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    mainFrame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 4)
    
    -- Name Label
    local nameLabel = Instance.new("TextLabel", mainFrame)
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = ESPConfig.PlayerColor
    nameLabel.TextSize = ESPConfig.TextSize
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    
    -- Distance Label
    local distanceLabel = Instance.new("TextLabel", mainFrame)
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(1, 0, 0.3, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.4, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = "0m"
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.TextSize = ESPConfig.TextSize - 2
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextStrokeTransparency = 0
    distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    
    -- Health Bar Background
    local healthBarBG = Instance.new("Frame", mainFrame)
    healthBarBG.Name = "HealthBarBG"
    healthBarBG.Size = UDim2.new(0.8, 0, 0.1, 0)
    healthBarBG.Position = UDim2.new(0.1, 0, 0.8, 0)
    healthBarBG.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    healthBarBG.BorderSizePixel = 0
    
    local healthBarCorner = Instance.new("UICorner", healthBarBG)
    healthBarCorner.CornerRadius = UDim.new(0, 2)
    
    -- Health Bar
    local healthBar = Instance.new("Frame", healthBarBG)
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = ESPConfig.HealthBarColor
    healthBar.BorderSizePixel = 0
    
    local healthCorner = Instance.new("UICorner", healthBar)
    healthCorner.CornerRadius = UDim.new(0, 2)
    
    -- Create Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight_" .. player.Name
    highlight.FillColor = ESPConfig.PlayerColor
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.FillTransparency = ESPConfig.HighlightTransparency
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    -- Store ESP data
    espData.BillboardGui = billboardGui
    espData.Highlight = highlight
    espData.NameLabel = nameLabel
    espData.DistanceLabel = distanceLabel
    espData.HealthBar = healthBar
    
    ESPObjects[player] = espData
    Statistics.PlayersTracked = Statistics.PlayersTracked + 1
    
    CensuraG.Logger:info("Created ESP for player: " .. player.Name)
end

local function updateESPForPlayer(player)
    local espData = ESPObjects[player]
    if not espData then return end
    
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local localRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not character or not rootPart or not localRootPart then
        -- Hide ESP if character not available
        if espData.BillboardGui then
            espData.BillboardGui.Enabled = false
        end
        if espData.Highlight then
            espData.Highlight.Enabled = false
        end
        return
    end
    
    -- Calculate distance
    local distance = (rootPart.Position - localRootPart.Position).Magnitude
    
    -- Check if within max distance
    if distance > ESPConfig.MaxDistance then
        espData.BillboardGui.Enabled = false
        espData.Highlight.Enabled = false
        return
    end
    
    -- Enable ESP elements if within range
    espData.BillboardGui.Enabled = ESPConfig.Enabled and ESPConfig.ShowPlayers
    espData.Highlight.Enabled = ESPConfig.Enabled and ESPConfig.ShowHighlights
    
    -- Update distance
    if ESPConfig.ShowDistance and espData.DistanceLabel then
        espData.DistanceLabel.Text = math.floor(distance) .. "m"
        espData.DistanceLabel.Visible = true
    else
        espData.DistanceLabel.Visible = false
    end
    
    -- Update health
    if ESPConfig.ShowHealth and humanoid and espData.HealthBar then
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        espData.HealthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
        
        -- Color based on health
        if healthPercent > 0.6 then
            espData.HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green
        elseif healthPercent > 0.3 then
            espData.HealthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
        else
            espData.HealthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Red
        end
        
        espData.HealthBar.Parent.Visible = true
    else
        espData.HealthBar.Parent.Visible = false
    end
    
    -- Attach GUI and Highlight to character
    if espData.BillboardGui.Enabled then
        espData.BillboardGui.Adornee = rootPart
        espData.BillboardGui.Parent = game.CoreGui
    end
    
    if espData.Highlight.Enabled then
        espData.Highlight.Adornee = character
        espData.Highlight.Parent = game.CoreGui
    end
    
    Statistics.TotalUpdates = Statistics.TotalUpdates + 1
end

local function removeESPForPlayer(player)
    local espData = ESPObjects[player]
    if not espData then return end
    
    if espData.BillboardGui then espData.BillboardGui:Destroy() end
    if espData.Highlight then espData.Highlight:Destroy() end
    
    ESPObjects[player] = nil
    Statistics.PlayersTracked = math.max(0, Statistics.PlayersTracked - 1)
    
    CensuraG.Logger:info("Removed ESP for player: " .. player.Name)
end

-- ESP Update Loop
local function startESPLoop()
    ESPConnections.UpdateLoop = RunService.Heartbeat:Connect(function()
        if not ESPConfig.Enabled then return end
        
        local currentTime = tick()
        if currentTime - Statistics.LastUpdate < ESPConfig.UpdateRate then
            return
        end
        
        Statistics.LastUpdate = currentTime
        
        for player, _ in pairs(ESPObjects) do
            if player and player.Parent then
                updateESPForPlayer(player)
            else
                removeESPForPlayer(player)
            end
        end
    end)
end

-- Player Management
local function onPlayerAdded(player)
    createESPForPlayer(player)
end

local function onPlayerRemoving(player)
    removeESPForPlayer(player)
end

-- Initialize ESP for existing players
for _, player in pairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

-- Connect player events
ESPConnections.PlayerAdded = Players.PlayerAdded:Connect(onPlayerAdded)
ESPConnections.PlayerRemoving = Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Start ESP loop
startESPLoop()

-- Create Desktop Icon for ESP
CensuraG.CreateDesktopIcon("ESP Tool", "rbxassetid://0", function()
    if mainWindow then
        mainWindow:BringToFront()
    end
end)

-- Wait a moment for CensuraG to fully load
wait(1)

-- === CensuraG Windows Creation ===

-- 1. Main ESP Control Window
local mainWindow = CensuraG.CreateWindow("CensuraG ESP v1.0")
if mainWindow then
    -- ESP Toggle
    local espToggle = CensuraG.Methods:CreateSwitch(
        mainWindow.ContentFrame,
        "Enable ESP",
        ESPConfig.Enabled,
        function(enabled)
            ESPConfig.Enabled = enabled
            CensuraG.Logger:info("ESP " .. (enabled and "enabled" or "disabled"))
        end
    )
    
    -- Player ESP Toggle
    local playerToggle = CensuraG.Methods:CreateSwitch(
        mainWindow.ContentFrame,
        "Show Players",
        ESPConfig.ShowPlayers,
        function(enabled)
            ESPConfig.ShowPlayers = enabled
        end
    )
    
    -- Distance Toggle
    local distanceToggle = CensuraG.Methods:CreateSwitch(
        mainWindow.ContentFrame,
        "Show Distance",
        ESPConfig.ShowDistance,
        function(enabled)
            ESPConfig.ShowDistance = enabled
        end
    )
    
    -- Health Toggle
    local healthToggle = CensuraG.Methods:CreateSwitch(
        mainWindow.ContentFrame,
        "Show Health",
        ESPConfig.ShowHealth,
        function(enabled)
            ESPConfig.ShowHealth = enabled
        end
    )
    
    -- Highlights Toggle
    local highlightToggle = CensuraG.Methods:CreateSwitch(
        mainWindow.ContentFrame,
        "Show Highlights",
        ESPConfig.ShowHighlights,
        function(enabled)
            ESPConfig.ShowHighlights = enabled
        end
    )
    
    -- Max Distance Slider
    local distanceSlider = CensuraG.Methods:CreateSlider(
        mainWindow.ContentFrame,
        "Max Distance",
        100,
        2000,
        ESPConfig.MaxDistance,
        function(value)
            ESPConfig.MaxDistance = value
        end
    )
    
    -- Update Rate Slider
    local updateSlider = CensuraG.Methods:CreateSlider(
        mainWindow.ContentFrame,
        "Update Rate (ms)",
        50,
        500,
        ESPConfig.UpdateRate * 1000,
        function(value)
            ESPConfig.UpdateRate = value / 1000
        end
    )
    
    -- Theme Selector
    local themeDropdown = CensuraG.Methods:CreateDropdown(
        mainWindow.ContentFrame,
        "ESP Theme",
        {"Green", "Red", "Blue", "Purple", "Orange"},
        function(selectedTheme)
            if selectedTheme == "Green" then
                ESPConfig.PlayerColor = Color3.fromRGB(0, 255, 0)
            elseif selectedTheme == "Red" then
                ESPConfig.PlayerColor = Color3.fromRGB(255, 0, 0)
            elseif selectedTheme == "Blue" then
                ESPConfig.PlayerColor = Color3.fromRGB(0, 100, 255)
            elseif selectedTheme == "Purple" then
                ESPConfig.PlayerColor = Color3.fromRGB(128, 0, 255)
            elseif selectedTheme == "Orange" then
                ESPConfig.PlayerColor = Color3.fromRGB(255, 128, 0)
            end
            CensuraG.Logger:info("ESP theme changed to: " .. selectedTheme)
        end
    )
    
    -- Control Buttons
    local refreshButton = CensuraG.Methods:CreateButton(
        mainWindow.ContentFrame,
        "Refresh ESP",
        function()
            -- Recreate ESP for all players
            for player, _ in pairs(ESPObjects) do
                removeESPForPlayer(player)
                createESPForPlayer(player)
            end
            CensuraG.Logger:info("ESP refreshed for all players")
        end
    )
    
    local clearButton = CensuraG.Methods:CreateButton(
        mainWindow.ContentFrame,
        "Clear All ESP",
        function()
            for player, _ in pairs(ESPObjects) do
                removeESPForPlayer(player)
            end
            CensuraG.Logger:info("All ESP cleared")
        end
    )
    
    -- Add components to window
    mainWindow.Window:AddComponent(espToggle)
    mainWindow.Window:AddComponent(playerToggle)
    mainWindow.Window:AddComponent(distanceToggle)
    mainWindow.Window:AddComponent(healthToggle)
    mainWindow.Window:AddComponent(highlightToggle)
    mainWindow.Window:AddComponent(distanceSlider)
    mainWindow.Window:AddComponent(updateSlider)
    mainWindow.Window:AddComponent(themeDropdown)
    mainWindow.Window:AddComponent(refreshButton)
    mainWindow.Window:AddComponent(clearButton)
    
    CensuraG.Logger:info("Main ESP window created with all controls")
end

-- 2. Statistics Window
local statsWindow = CensuraG.CreateWindow("ESP Statistics")
if statsWindow then
    local playersLabel = CensuraG.Methods:CreateLabel(statsWindow.ContentFrame, "Players Tracked: 0")
    local updatesLabel = CensuraG.Methods:CreateLabel(statsWindow.ContentFrame, "Total Updates: 0")
    local uptimeLabel = CensuraG.Methods:CreateLabel(statsWindow.ContentFrame, "Uptime: 0s")
    local fpsLabel = CensuraG.Methods:CreateLabel(statsWindow.ContentFrame, "FPS: 0")
    local memoryLabel = CensuraG.Methods:CreateLabel(statsWindow.ContentFrame, "Memory: 0 MB")
    
    statsWindow.Window:AddComponent(playersLabel)
    statsWindow.Window:AddComponent(updatesLabel)
    statsWindow.Window:AddComponent(uptimeLabel)
    statsWindow.Window:AddComponent(fpsLabel)
    statsWindow.Window:AddComponent(memoryLabel)
    
    -- Update statistics every second
    ESPConnections.StatsUpdate = RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        if currentTime % 1 < 0.1 then -- Update roughly every second
            playersLabel.Instance.Text = "Players Tracked: " .. Statistics.PlayersTracked
            updatesLabel.Instance.Text = "Total Updates: " .. Statistics.TotalUpdates
            uptimeLabel.Instance.Text = "Uptime: " .. math.floor(currentTime - Statistics.StartTime) .. "s"
            
            -- Calculate FPS
            local fps = math.floor(1 / RunService.Heartbeat:Wait())
            fpsLabel.Instance.Text = "FPS: " .. fps
            
            -- Memory usage (approximation)
            local memory = math.floor(collectgarbage("count") / 1024 * 100) / 100
            memoryLabel.Instance.Text = "Memory: " .. memory .. " MB"
        end
    end)
    
    CensuraG.Logger:info("Statistics window created")
end

-- 3. About Window
local aboutWindow = CensuraG.CreateWindow("About CensuraG ESP")
if aboutWindow then
    local titleLabel = CensuraG.Methods:CreateLabel(aboutWindow.ContentFrame, "CensuraG ESP v1.0")
    local descLabel = CensuraG.Methods:CreateLabel(aboutWindow.ContentFrame, "Advanced ESP tool built with CensuraG Desktop Environment")
    local authorLabel = CensuraG.Methods:CreateLabel(aboutWindow.ContentFrame, "Created for CensuraG Testing")
    local featuresLabel = CensuraG.Methods:CreateLabel(aboutWindow.ContentFrame, "Features:")
    local feature1Label = CensuraG.Methods:CreateLabel(aboutWindow.ContentFrame, "• Player ESP with distance and health")
    local feature2Label = CensuraG.Methods:CreateLabel(aboutWindow.ContentFrame, "• Real-time statistics tracking")
    local feature3Label = CensuraG.Methods:CreateLabel(aboutWindow.ContentFrame, "• Desktop environment integration")
    local feature4Label = CensuraG.Methods:CreateLabel(aboutWindow.ContentFrame, "• Multiple themed windows")
    
    local testButton = CensuraG.Methods:CreateButton(
        aboutWindow.ContentFrame,
        "Test Desktop Features",
        function()
            CensuraG.Logger:info("Testing desktop features...")
            
            -- Test window management
            task.spawn(function()
                wait(1)
                CensuraG.TileWindows()
                wait(3)
                CensuraG.CascadeWindows()
            end)
        end
    )
    
    aboutWindow.Window:AddComponent(titleLabel)
    aboutWindow.Window:AddComponent(descLabel)
    aboutWindow.Window:AddComponent(authorLabel)
    aboutWindow.Window:AddComponent(featuresLabel)
    aboutWindow.Window:AddComponent(feature1Label)
    aboutWindow.Window:AddComponent(feature2Label)
    aboutWindow.Window:AddComponent(feature3Label)
    aboutWindow.Window:AddComponent(feature4Label)
    aboutWindow.Window:AddComponent(testButton)
    
    CensuraG.Logger:info("About window created")
end

-- Position windows nicely
wait(0.5)
if mainWindow then mainWindow:SetSize(350, 450) end
if statsWindow then 
    statsWindow:SetSize(250, 200)
    -- Position stats window to the right of main window
    if statsWindow.Frame then
        statsWindow.Frame.Position = UDim2.new(0, 400, 0, 100)
    end
end
if aboutWindow then 
    aboutWindow:SetSize(300, 350)
    -- Position about window below main window
    if aboutWindow.Frame then
        aboutWindow.Frame.Position = UDim2.new(0, 100, 0, 300)
    end
end

-- Cleanup function
local function cleanup()
    CensuraG.Logger:info("Cleaning up ESP application...")
    
    -- Disconnect all connections
    for name, connection in pairs(ESPConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Remove all ESP objects
    for player, _ in pairs(ESPObjects) do
        removeESPForPlayer(player)
    end
    
    CensuraG.Logger:info("ESP application cleanup completed")
end

-- Handle script termination
game:GetService("Players").LocalPlayer.AncestryChanged:Connect(function()
    cleanup()
end)

-- Success message
CensuraG.Logger:section("ESP Application Loaded")
CensuraG.Logger:info("CensuraG ESP v1.0 successfully loaded!")
CensuraG.Logger:info("Desktop Environment Test: Active")
CensuraG.Logger:info("Windows Created: Main Control, Statistics, About")
CensuraG.Logger:info("Players Being Tracked: " .. #Players:GetPlayers())

-- Desktop notifications (if available)
if CensuraG.Desktop then
    spawn(function()
        wait(2)
        -- Create some test desktop icons
        CensuraG.CreateDesktopIcon("Settings", "rbxassetid://0", function()
            CensuraG.Desktop:OpenSettings()
        end)
        
        CensuraG.CreateDesktopIcon("Statistics", "rbxassetid://0", function()
            if statsWindow then
                statsWindow:BringToFront()
            end
        end)
    end)
end

print("🖥️ CensuraG ESP loaded successfully! Right-click desktop for options, try window snapping and management features!")