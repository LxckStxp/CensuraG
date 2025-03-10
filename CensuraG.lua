-- CensuraG.lua: Entry point for the CensuraG UI API
-- This script initializes the CensuraG UI framework, loading dependencies and setting up the core environment.
local CensuraG = {}
_G.CensuraG = CensuraG

-- Base URLs for fetching external scripts
local oratioBaseUrl = "https://raw.githubusercontent.com/LxckStxp/Oratio/main/"
local censuraBaseUrl = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/"

-- Utility function to load and compile remote scripts
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

-- Load and initialize Oratio logging system
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

-- Configure and assign logger
local logger = Oratio.new({
    moduleName = "CensuraG",
    minLevel = "DEBUG",
    formatter = Oratio.Modules.Formatters.default,
    storeHistory = true,
    outputEnabled = true
})
CensuraG.Logger = logger
logger:info("CensuraG initialization started.")

-- Load all required modules
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
    ImageLabel = loadScript(censuraBaseUrl, "Elements/ImageLabel.lua"),
    Slider = loadScript(censuraBaseUrl, "Elements/Slider.lua"),
    Switch = loadScript(censuraBaseUrl, "Elements/Switch.lua"),
    Cluster = loadScript(censuraBaseUrl, "Elements/Cluster.lua")
}

-- Execute and assign loaded modules
for moduleName, scriptFunc in pairs(scripts) do
    if scriptFunc then
        local success, result = pcall(scriptFunc)
        if success and result then
            CensuraG[moduleName] = result
            logger:debug("Loaded module: %s", moduleName)
        else
            logger:error("Failed to execute module: %s, Error: %s", moduleName, tostring(result or "No error details"))
        end
    else
        logger:warn("Failed to load module: %s (script not fetched)", moduleName)
    end
end

-- Validate required modules
local requiredModules = {"Utilities", "UIElement", "Styling", "Animation", "Draggable", "WindowManager", "Taskbar", "Window", "TextButton", "Slider", "Switch", "Cluster", "ImageLabel"}
for _, moduleName in ipairs(requiredModules) do
    if not CensuraG[moduleName] then
        logger:error("Required module %s is missing after loading", moduleName)
    end
end

-- Initialize GUI environment
local function initializeGuiEnvironment()
    local success, playerGui
    repeat
        success, playerGui = pcall(function()
            local Players = game:GetService("Players")
            return Players.LocalPlayer and Players.LocalPlayer:WaitForChild("PlayerGui")
        end)
        if not success or not playerGui then
            logger:warn("Waiting for PlayerGui, retrying in 0.1 seconds...")
            task.wait(0.1)
        end
    until success and playerGui

    if not success or not playerGui then
        logger:error("Failed to access PlayerGui after retries: %s", tostring(playerGui))
        return false
    end

    CensuraG.ScreenGui = playerGui:FindFirstChild("CensuraGGui") or CensuraG.Utilities.createInstance("ScreenGui", {
        Parent = playerGui,
        Name = "CensuraGGui",
        ResetOnSpawn = false
    })

    if not CensuraG.ScreenGui or not CensuraG.ScreenGui:IsA("ScreenGui") then
        logger:error("ScreenGui initialization failed: %s is not a valid ScreenGui", tostring(CensuraG.ScreenGui))
        return false
    end

    logger:info("ScreenGui initialized: %s", CensuraG.ScreenGui.Name)
    return true
end

-- Attempt to initialize GUI environment
if not initializeGuiEnvironment() then
    logger:error("GUI environment initialization failed. Aborting CensuraG setup.")
    return CensuraG
end

-- Add custom element functionality
function CensuraG.AddCustomElement(name, class)
    if not name or not class then
        logger:warn("Invalid parameters for AddCustomElement: name=%s, class=%s", tostring(name), tostring(class))
        return
    end
    CensuraG[name] = class
    logger:debug("Added custom element: %s", name)
end

-- Initialize core managers
local function initializeManagers()
    if CensuraG.WindowManager and type(CensuraG.WindowManager.Init) == "function" then
        CensuraG.WindowManager:Init()
        logger:info("WindowManager initialized.")
    else
        logger:error("WindowManager failed to initialize or Init method is missing.")
    end

    if CensuraG.Taskbar and type(CensuraG.Taskbar.Init) == "function" then
        CensuraG.Taskbar:Init()
        logger:info("Taskbar initialized.")
    else
        logger:error("Taskbar failed to initialize or Init method is missing.")
    end
end

initializeManagers()
logger:info("CensuraG initialization completed.")
return CensuraG
