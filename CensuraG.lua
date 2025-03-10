-- CensuraG.lua: Entry point for the CensuraG UI API
local CensuraG = {}
_G.CensuraG = CensuraG

local oratioBaseUrl = "https://raw.githubusercontent.com/LxckStxp/Oratio/main/"
local censuraBaseUrl = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/"

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

-- Load Oratio logger
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

local logger = Oratio.new({
    moduleName = "CensuraG",
    minLevel = "DEBUG",
    formatter = Oratio.Modules.Formatters.default,
    storeHistory = true,
    outputEnabled = true
})
CensuraG.Logger = logger
logger:info("CensuraG initialization started.")

-- Load modules
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
        logger:warn("Failed to load module: %s", moduleName)
    end
end

-- Initialize ScreenGui
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
if not playerGui then
    logger:error("Failed to access PlayerGui")
    return CensuraG
end

CensuraG.ScreenGui = playerGui:FindFirstChild("CensuraGGui") or CensuraG.Utilities.createInstance("ScreenGui", {
    Parent = playerGui,
    Name = "CensuraGGui",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})
logger:info("ScreenGui initialized: %s", CensuraG.ScreenGui.Name)

-- Wait for ScreenGui size
local maxWait = 5
local waitTime = 0
repeat
    task.wait(0.1)
    waitTime = waitTime + 0.1
until (CensuraG.ScreenGui.AbsoluteSize and CensuraG.ScreenGui.AbsoluteSize.X > 0) or waitTime > maxWait
if waitTime > maxWait then
    logger:warn("ScreenGui size not available after %d seconds", maxWait)
end

function CensuraG.AddCustomElement(name, class)
    if not name or not class then
        logger:warn("Invalid parameters for AddCustomElement: name=%s, class=%s", tostring(name), tostring(class))
        return
    end
    CensuraG[name] = class
    logger:debug("Added custom element: %s", name)
end

local function initializeManagers()
    if CensuraG.WindowManager then
        CensuraG.WindowManager:Init()
        logger:info("WindowManager initialized")
    end
    if CensuraG.Taskbar then
        CensuraG.Taskbar:Init()
        logger:info("Taskbar initialized")
    end
end

initializeManagers()
logger:info("CensuraG initialization completed.")
return CensuraG
