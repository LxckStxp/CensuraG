-- uiTest.lua: Showcase CensuraG UI API
local censuraBaseUrl = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/"
local CensuraG = loadstring(game:HttpGet(censuraBaseUrl .. "CensuraG.lua", true))()
if not CensuraG then error("CensuraG failed to initialize") end
_G.CensuraG = CensuraG

local logger = CensuraG.Logger
task.wait(1) -- Ensure ScreenGui is ready

-- Create ESP Window
local espWindow = CensuraG.Window.new("ESP Controls", 0, 0, 300, 200)
local espSwitch = CensuraG.Switch.new(espWindow, 10, 30, 40, 20, false, {
    LabelText = "ESP Enabled",
    ShowLabel = true,
    OnToggled = function(state) print("ESP: " .. tostring(state)) end
})
local espDistance = CensuraG.Slider.new(espWindow, 10, 70, 200, 0, 1000, 200, {
    LabelText = "Distance",
    ShowValue = true,
    OnChanged = function(value) print("Distance: " .. value) end
})
local refreshButton = CensuraG.TextButton.new(espWindow, "Refresh", 10, 110, 120, 30, function()
    print("ESP Refreshed")
end)

-- Create Settings Window
local settingsWindow = CensuraG.Window.new("Settings", 0, 0, 300, 200)
local darkModeSwitch = CensuraG.Switch.new(settingsWindow, 10, 30, 40, 20, true, {
    LabelText = "Dark Mode",
    ShowLabel = true,
    OnToggled = function(state) print("Dark Mode: " .. tostring(state)) end
})
local resetButton = CensuraG.TextButton.new(settingsWindow, "Reset", 10, 70, 120, 30, function()
    print("Settings Reset")
end)

-- Test interactions
task.wait(2)
espWindow:Minimize()
task.wait(1)
espWindow:Maximize()
settingsWindow:Minimize()
task.wait(1)
settingsWindow:Maximize()

logger:info("Test complete, cleaning up")
espWindow:Destroy()
settingsWindow:Destroy()
