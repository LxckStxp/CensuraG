-- uiTest.lua: Simple example to showcase building ESP menus with CensuraG UI API
local censuraBaseUrl = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/"

-- Load CensuraG framework
local success, result = pcall(function()
    return game:HttpGet(censuraBaseUrl .. "CensuraG.lua", true)
end)
if not success then error("Failed to fetch CensuraG.lua: " .. result) end

local censuragFunc, err = loadstring(result)
if not censuragFunc then error("Failed to compile CensuraG.lua: " .. err) end

local CensuraG = censuragFunc()
if not CensuraG then error("CensuraG initialization failed") end

_G.CensuraG = CensuraG

local logger = CensuraG.Logger
if not logger then error("CensuraG.Logger not initialized") end

-- Wait for ScreenGui to be ready
local maxWait = 5
local waitTime = 0
repeat
    task.wait(0.1)
    waitTime = waitTime + 0.1
    if waitTime > maxWait then
        logger:warn("ScreenGui not fully initialized after %d seconds, proceeding", maxWait)
        break
    end
until CensuraG.ScreenGui and CensuraG.ScreenGui.AbsoluteSize and CensuraG.ScreenGui.AbsoluteSize.Y > 0
logger:info("Starting ESP menu showcase with CensuraG")

-- Initialize Taskbar
local taskbar = CensuraG.Taskbar and CensuraG.Taskbar:Init() or nil
if taskbar then logger:info("Taskbar initialized") else logger:warn("Taskbar not available") end

-- Create ESP Control Window
local espWindow = CensuraG.Window.new("ESP Controls", 0, 0, 300, 200) -- Specify size
if espWindow then
    logger:info("ESP Controls window created")
    -- Add ESP Toggle Switch with error handling
    local success, espSwitch = pcall(function() return CensuraG.Switch.new(espWindow, 10, 30, 40, 20, false, {
        LabelText = "ESP Enabled",
        ShowLabel = true,
        OnToggled = function(state)
            logger:info("ESP toggled to: " .. tostring(state))
            if state then
                print("ESP Enabled")
            else
                print("ESP Disabled")
            end
        end
    }) end)
    if not success then logger:error("Failed to create ESP Switch: %s", tostring(espSwitch)) end

    -- Add ESP Distance Slider with error handling
    local success, espDistance = pcall(function() return CensuraG.Slider.new(espWindow, 10, 80, 200, 0, 1000, 200, {
        LabelText = "ESP Distance",
        ShowValue = true,
        OnChanged = function(value)
            logger:info("ESP Distance set to: " .. value)
            print("ESP Distance: " .. value)
        end
    }) end)
    if not success then logger:error("Failed to create ESP Distance Slider: %s", tostring(espDistance)) end

    -- Add Refresh Button with error handling
    local success, refreshButton = pcall(function() return CensuraG.TextButton.new(espWindow, "Refresh ESP", 10, 130, 120, 30, function()
        logger:info("Refresh ESP clicked")
        print("ESP Refreshed")
    end) end)
    if not success then logger:error("Failed to create Refresh Button: %s", tostring(refreshButton)) end
end

-- Create Settings Window
local settingsWindow = CensuraG.Window.new("Settings", 0, 0, 300, 200) -- Specify size
if settingsWindow then
    logger:info("Settings window created")
    -- Add Dark Mode Switch with error handling
    local success, darkModeSwitch = pcall(function() return CensuraG.Switch.new(settingsWindow, 10, 30, 40, 20, true, {
        LabelText = "Dark Mode",
        ShowLabel = true,
        OnToggled = function(state)
            logger:info("Dark Mode toggled to: " .. tostring(state))
            print("Dark Mode: " .. tostring(state))
        end
    }) end)
    if not success then logger:error("Failed to create Dark Mode Switch: %s", tostring(darkModeSwitch)) end

    -- Add Reset Button with error handling
    local success, resetButton = pcall(function() return CensuraG.TextButton.new(settingsWindow, "Reset Settings", 10, 80, 120, 30, function()
        logger:info("Reset Settings clicked")
        print("Settings Reset")
    end) end)
    if not success then logger:error("Failed to create Reset Button: %s", tostring(resetButton)) end
end

-- Ensure windows are added to WindowManager
if espWindow then CensuraG.WindowManager:AddWindow(espWindow) end
if settingsWindow then CensuraG.WindowManager:AddWindow(settingsWindow) end

-- Test interactions
logger:info("Starting UI interaction test")
task.wait(2)

-- Minimize and maximize windows
if espWindow then
    espWindow:Minimize()
    logger:info("Minimized ESP Controls")
    task.wait(1)
    espWindow:Maximize()
    logger:info("Maximized ESP Controls")
end
if settingsWindow then
    settingsWindow:Minimize()
    logger:info("Minimized Settings")
    task.wait(1)
    settingsWindow:Maximize()
    logger:info("Maximized Settings")
end

-- Test prolonged usage
logger:info("Running test for 30 seconds to observe taskbar and cluster")
logger:info("Move mouse to bottom 20% of screen to show taskbar")
for i = 1, 30 do
    task.wait(1)
    logger:debug("Test running for %d seconds", i)
end

-- Cleanup
logger:info("Cleaning up")
if espWindow then espWindow:Destroy() end
if settingsWindow then settingsWindow:Destroy() end
if taskbar then taskbar:Destroy() end
