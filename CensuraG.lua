-- CensuraG.lua: Entry point for the CensuraG UI API
-- Loads Oratio logging system first, then other scripts dynamically
local CensuraG = {}
_G.CensuraG = CensuraG

-- Base URLs for repositories
local oratioBaseUrl = "https://raw.githubusercontent.com/LxckStxp/Oratio/main/"
local censuraBaseUrl = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/"

-- Load a script from a given URL (returns a function, doesn't execute it)
local function loadScript(url, path)
    local success, result = pcall(function()
        return game:HttpGet(url .. path, true)
    end)
    if not success then
        warn("Failed to fetch script " .. path .. ": " .. result)
        return nil
    end
    local scriptFunc, err = loadstring(result)
    if not scriptFunc then
        warn("Failed to compile script " .. path .. ": " .. err)
        return nil
    end
    return scriptFunc
end

-- Load Oratio first
local OratioFunc = loadScript(oratioBaseUrl, "init.lua")
if not OratioFunc then
    warn("Critical: Oratio logging system failed to load. Aborting CensuraG initialization.")
    return CensuraG
end
local Oratio = OratioFunc()
if not Oratio then
    warn("Critical: Oratio initialization failed.")
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

-- Load all CensuraG scripts as functions (don't execute yet)
local scripts = {
    Utilities = loadScript(censuraBaseUrl, "Utilities.lua"),
    UIElement = loadScript(censuraBaseUrl, "UIElement.lua"),
    Styling = loadScript(censuraBaseUrl, "Styling.lua"),
    Animation = loadScript(censuraBaseUrl, "Animation.lua"),
    Draggable = loadScript(censuraBaseUrl, "Draggable.lua"),
    WindowManager = loadScript(censuraBaseUrl, "WindowManager.lua"),
    Taskbar = loadScript(censuraBaseUrl, "Taskbar.lua"),
    Window = loadScript(censuraBaseUrl, "Elements/Window.lua"),
    TextButton = loadScript(censuraBaseUrl, "Elements/TextButton.lua"),
    Slider = loadScript(censuraBaseUrl, "Elements/Slider.lua"),
    Switch = loadScript(censuraBaseUrl, "Elements/Switch.lua")
}

-- Assign all modules to CensuraG (execute scripts after all are loaded)
for moduleName, scriptFunc in pairs(scripts) do
    if scriptFunc then
        local success, result = pcall(scriptFunc)
        if success and result then
            CensuraG[moduleName] = result
            logger:debug("Loaded module: %s", moduleName)
        else
            logger:error("Failed to execute module: %s, Error: %s", moduleName, tostring(result))
        end
    else
        logger:warn("Failed to load module: %s (script not fetched)", moduleName)
    end
end

-- Verify all required modules are loaded
local requiredModules = {"Utilities", "UIElement", "Styling", "Animation", "Draggable", "WindowManager", "Taskbar", "Window", "TextButton", "Slider", "Switch"}
for _, moduleName in ipairs(requiredModules) do
    if not CensuraG[moduleName] then
        logger:error("Required module %s is missing after loading", moduleName)
    end
end

-- Initialize ScreenGui
local success, playerGui = pcall(function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    return LocalPlayer:WaitForChild("PlayerGui")
end)
if not success or not playerGui then
    logger:error("Failed to access PlayerGui: %s", tostring(playerGui))
    return CensuraG
end

CensuraG.ScreenGui = playerGui:FindFirstChild("CensuraGGui") or CensuraG.Utilities.createInstance("ScreenGui", {
    Parent = playerGui,
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
