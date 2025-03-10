-- CensuraG.lua: Entry point for the CensuraG UI API
-- Loads Oratio logging system first, then other scripts dynamically
local CensuraG = {}
_G.CensuraG = CensuraG

-- Base URLs for repositories
local oratioBaseUrl = "https://raw.githubusercontent.com/LxckStxp/Oratio/main/"
local censuraBaseUrl = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/"

-- Load a script from a given URL
local function loadScript(url, path)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url .. path, true))()
    end)
    if not success then
        warn("Failed to load " .. path .. ": " .. result)
        return nil
    end
    return result
end

-- Load Oratio first
local Oratio = loadScript(oratioBaseUrl, "init.lua")
if not Oratio then
    warn("Critical: Oratio logging system failed to load. Aborting CensuraG initialization.")
    return CensuraG
end

-- Create a global logger for CensuraG
local logger = Oratio.new({
    moduleName = "CensuraG",
    minLevel = "DEBUG",
    formatter = Oratio.Modules.Formatters.default,
    storeHistory = true,
    outputEnabled = true
})
CensuraG.Logger = logger
logger:info("CensuraG initialization started.")

-- Load CensuraG dependencies
CensuraG.Utilities = loadScript(censuraBaseUrl, "Utilities.lua")
CensuraG.UIElement = loadScript(censuraBaseUrl, "UIElement.lua")
CensuraG.Styling = loadScript(censuraBaseUrl, "Styling.lua")
CensuraG.Animation = loadScript(censuraBaseUrl, "Animation.lua")
CensuraG.Draggable = loadScript(censuraBaseUrl, "Draggable.lua")
CensuraG.WindowManager = loadScript(censuraBaseUrl, "WindowManager.lua")
CensuraG.Taskbar = loadScript(censuraBaseUrl, "Taskbar.lua")
CensuraG.Window = loadScript(censuraBaseUrl, "Elements/Window.lua")
CensuraG.TextButton = loadScript(censuraBaseUrl, "Elements/TextButton.lua")
CensuraG.Slider = loadScript(censuraBaseUrl, "Elements/Slider.lua")
CensuraG.Switch = loadScript(censuraBaseUrl, "Elements/Switch.lua")

-- Log successful/failed loads
for moduleName, module in pairs(CensuraG) do
    if moduleName ~= "Logger" and moduleName ~= "ScreenGui" then
        if module then
            logger:debug("Loaded module: %s", moduleName)
        else
            logger:warn("Failed to load module: %s", moduleName)
        end
    end
end

-- Initialize ScreenGui
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
CensuraG.ScreenGui = PlayerGui:FindFirstChild("CensuraGGui") or CensuraG.Utilities.createInstance("ScreenGui", {
    Parent = PlayerGui,
    Name = "CensuraGGui",
    ResetOnSpawn = false
})
logger:info("ScreenGui initialized: %s", CensuraG.ScreenGui.Name)

-- API extension method
function CensuraG.AddCustomElement(name, class)
    CensuraG[name] = class
    logger:debug("Added custom element: %s", name)
end

-- Initialize WindowManager and Taskbar
if CensuraG.WindowManager then
    CensuraG.WindowManager:Init()
    logger:info("WindowManager initialized.")
else
    logger:error("WindowManager failed to initialize.")
end

if CensuraG.Taskbar then
    CensuraG.Taskbar:Init()
    logger:info("Taskbar initialized.")
else
    logger:error("Taskbar failed to initialize.")
end

logger:info("CensuraG initialization completed.")
return CensuraG
