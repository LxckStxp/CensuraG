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

local scripts = {
    Utilities = loadScript(censuraBaseUrl, "Utilities.lua"),
    UIElement = loadScript(censuraBaseUrl, "UIElement.lua"), -- Fixed typo: censuraUrl to censuraBaseUrl
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
            logger:debug("Loaded and executed module: %s, Result: %s", moduleName, tostring(result))
        else
            logger:error("Failed to execute module: %s, Error: %s", moduleName, tostring(result or "No error"))
        end
    else
        logger:warn("Failed to load module: %s (script not fetched)", moduleName)
    end
end

local requiredModules = {"Utilities", "UIElement", "Styling", "Animation", "Draggable", "WindowManager", "Taskbar", "Window", "TextButton", "Slider", "Switch", "Cluster", "ImageLabel"}
for _, moduleName in ipairs(requiredModules) do
    if not CensuraG[moduleName] then
        logger:error("Required module %s is missing after loading", moduleName)
    elseif type(CensuraG[moduleName].new) ~= "function" and moduleName ~= "WindowManager" and moduleName ~= "Taskbar" and moduleName ~= "Styling" and moduleName ~= "Animation" and moduleName ~= "Utilities" and moduleName ~= "Draggable" then
        logger:error("Module %s loaded but .new is not a function", moduleName)
    end
end

local success, playerGui = pcall(function()
    local Players = game:GetService("Players")
    repeat task.wait() until Players.LocalPlayer
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

if not CensuraG.ScreenGui or not CensuraG.ScreenGui:IsA("ScreenGui") then
    logger:error("ScreenGui initialization failed: %s is not a valid ScreenGui", tostring(CensuraG.ScreenGui))
    return CensuraG
end
logger:info("ScreenGui initialized: %s", CensuraG.ScreenGui.Name)

-- Wait for ScreenGui to have a valid size
local maxWait = 5
local waitTime = 0
repeat
    task.wait(0.1)
    waitTime = waitTime + 0.1
    if waitTime > maxWait then
        logger:warn("ScreenGui size not available after %d seconds, proceeding with default size (800x600)", maxWait)
        break
    end
until CensuraG.ScreenGui.AbsoluteSize and CensuraG.ScreenGui.AbsoluteSize.X > 0 and CensuraG.ScreenGui.AbsoluteSize.Y > 0
logger:info("ScreenGui size available: %s", tostring(CensuraG.ScreenGui.AbsoluteSize))

function CensuraG.AddCustomElement(name, class)
    if not name or not class then
        logger:warn("Invalid parameters for AddCustomElement: name=%s, class=%s", tostring(name), tostring(class))
        return
    end
    CensuraG[name] = class
    logger:debug("Added custom element: %s", name)
end

local function initializeManagers()
    if CensuraG.WindowManager and type(CensuraG.WindowManager.Init) == "function" then
        CensuraG.WindowManager:Init()
        logger:info("WindowManager initialized with WindowCount: %d, ZIndexCounter: %d", #CensuraG.WindowManager.Windows, CensuraG.WindowManager.ZIndexCounter)
    else
        logger:error("WindowManager or its Init function is missing.")
    end

    if CensuraG.Taskbar and type(CensuraG.Taskbar.Init) == "function" then
        CensuraG.Taskbar:Init()
        logger:info("Taskbar initialized.")
    else
        logger:error("Taskbar or its Init function is missing.")
    end
end

initializeManagers()
logger:info("CensuraG initialization completed.")
return CensuraG
