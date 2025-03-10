-- CensuraG/init.lua: Main entry point for the CensuraG UI Framework
local CensuraG = {
    _VERSION = "1.0.0",
    _DESCRIPTION = "Modern UI framework for Roblox exploits",
    _LICENSE = "MIT"
}

-- Base URLs for fetching modules
local baseUrl = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/"
local oratioBaseUrl = "https://raw.githubusercontent.com/LxckStxp/Oratio/main/"

-- Initialize global reference
_G.CensuraG = CensuraG

-- Safe module loading function
local function loadModule(modulePath)
    local success, result = pcall(function()
        return game:HttpGet(baseUrl .. modulePath, true)
    end)
    
    if not success then
        warn("Failed to fetch module " .. modulePath .. ": " .. result)
        return nil
    end
    
    local moduleFunc, err = loadstring(result)
    if not moduleFunc then
        warn("Failed to compile module " .. modulePath .. ": " .. err)
        return nil
    end
    
    local moduleResult
    success, moduleResult = pcall(moduleFunc)
    if not success then
        warn("Failed to execute module " .. modulePath .. ": " .. moduleResult)
        return nil
    end
    
    return moduleResult
end

-- Load Oratio logger first
local OratioFunc = loadstring(game:HttpGet(oratioBaseUrl .. "init.lua", true))
if not OratioFunc then
    warn("Critical: Oratio logging system failed to load. Using basic logging.")
    -- Implement basic logger as fallback
    CensuraG.Logger = {
        debug = function(_, ...) print("[DEBUG]", ...) end,
        info = function(_, ...) print("[INFO]", ...) end,
        warn = function(_, ...) print("[WARN]", ...) end,
        error = function(_, ...) warn("[ERROR]", ...) end,
        critical = function(_, ...) warn("[CRITICAL]", ...) end
    }
else
    local Oratio = OratioFunc()
    CensuraG.Logger = Oratio.new({
        moduleName = "CensuraG",
        minLevel = "DEBUG",
        formatter = Oratio.Modules.Formatters.default,
        storeHistory = true,
        outputEnabled = true
    })
end

CensuraG.Logger:info("CensuraG initialization started (v%s)", CensuraG._VERSION)

-- Define module loading order for proper dependencies
local moduleLoadOrder = {
    -- Core modules
    { name = "Utilities", path = "Core/Utilities.lua" },
    { name = "ErrorHandler", path = "Core/ErrorHandler.lua" },
    { name = "EventManager", path = "Core/EventManager.lua" },
    { name = "DependencyManager", path = "Core/DependencyManager.lua" },
    { name = "Styling", path = "Core/Styling.lua" },
    { name = "Animation", path = "Core/Animation.lua" },
    
    -- UI base modules
    { name = "UIElement", path = "UI/UIElement.lua" },
    { name = "Draggable", path = "UI/Draggable.lua" },
    { name = "WindowManager", path = "UI/WindowManager.lua" },
    { name = "Taskbar", path = "UI/Taskbar.lua" },
    
    -- UI elements
    { name = "Window", path = "Elements/Window.lua" },
    { name = "TextButton", path = "Elements/TextButton.lua" },
    { name = "ImageLabel", path = "Elements/ImageLabel.lua" },
    { name = "Slider", path = "Elements/Slider.lua" },
    { name = "Switch", path = "Elements/Switch.lua" },
    { name = "Dropdown", path = "Elements/Dropdown.lua" },
    { name = "Cluster", path = "Elements/Cluster.lua" },
    { name = "Settings", path = "Elements/Settings.lua" }
}

-- Load all modules in order
local criticalModules = {
    "Utilities", "ErrorHandler", "EventManager", "Styling", "Animation", "UIElement"
}

for _, moduleInfo in ipairs(moduleLoadOrder) do
    local moduleName = moduleInfo.name
    local modulePath = moduleInfo.path
    
    CensuraG.Logger:debug("Loading module: %s", moduleName)
    CensuraG[moduleName] = loadModule(modulePath)
    
    if not CensuraG[moduleName] then
        if table.find(criticalModules, moduleName) then
            CensuraG.Logger:critical("Critical module %s failed to load. Aborting initialization.", moduleName)
            return CensuraG
        else
            CensuraG.Logger:warn("Non-critical module %s failed to load. Continuing with limited functionality.", moduleName)
        end
    else
        CensuraG.Logger:debug("Successfully loaded module: %s", moduleName)
    end
end

-- Initialize ScreenGui
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    LocalPlayer = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
end

local playerGui = LocalPlayer:WaitForChild("PlayerGui", 5)
if not playerGui then
    CensuraG.Logger:error("Failed to access PlayerGui")
    return CensuraG
end

CensuraG.ScreenGui = playerGui:FindFirstChild("CensuraGGui")
if not CensuraG.ScreenGui then
    CensuraG.ScreenGui = CensuraG.Utilities.createInstance("ScreenGui", {
        Parent = playerGui,
        Name = "CensuraGGui",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
end
CensuraG.Logger:info("ScreenGui initialized: %s", CensuraG.ScreenGui.Name)

-- Wait for ScreenGui size to be available
local maxWait = 5
local waitTime = 0
repeat
    task.wait(0.1)
    waitTime = waitTime + 0.1
until (CensuraG.ScreenGui.AbsoluteSize and CensuraG.ScreenGui.AbsoluteSize.X > 0) or waitTime > maxWait

if waitTime > maxWait then
    CensuraG.Logger:warn("ScreenGui size not available after %d seconds", maxWait)
end

-- Initialize managers
if CensuraG.WindowManager then
    CensuraG.WindowManager:Init()
    CensuraG.Logger:info("WindowManager initialized")
end

if CensuraG.Taskbar then
    CensuraG.Taskbar:Init()
    CensuraG.Logger:info("Taskbar initialized")
end

-- Initialize settings menu
if CensuraG.Settings then
    task.spawn(function()
        -- Small delay to ensure everything else is loaded
        task.wait(0.5)
        CensuraG.Settings:Init()
        CensuraG.Logger:info("Settings menu auto-initialized")
    end)
end

-- API for adding custom elements
function CensuraG.AddCustomElement(name, class)
    if not name or not class then
        CensuraG.Logger:warn("Invalid parameters for AddCustomElement: name=%s, class=%s", tostring(name), tostring(class))
        return
    end
    CensuraG[name] = class
    CensuraG.Logger:debug("Added custom element: %s", name)
end

-- Add settings toggle to taskbar
function CensuraG.ToggleSettings()
    if CensuraG.Settings then
        CensuraG.Settings:Toggle()
    else
        CensuraG.Logger:warn("Settings module not loaded")
    end
end

-- Open settings directly
function CensuraG.OpenSettings()
    if CensuraG.Settings then
        CensuraG.Settings:Show()
    else
        CensuraG.Logger:warn("Settings module not loaded")
    end
end

-- Global configuration settings
CensuraG.Config = {
    EnableShadows = true,
    AnimationQuality = 1.0,
    AnimationSpeed = 1.0,
    WindowSnapEnabled = true,
    DebugMode = false
}

-- Clean up function for proper resource management
function CensuraG.Destroy()
    CensuraG.Logger:info("Destroying CensuraG framework...")
    
    if CensuraG.EventManager then
        CensuraG.EventManager:DisconnectAll()
    end
    
    if CensuraG.WindowManager then
        CensuraG.WindowManager:Destroy()
    end
    
    if CensuraG.Taskbar then
        CensuraG.Taskbar:Destroy()
    end
    
    if CensuraG.ScreenGui then
        CensuraG.ScreenGui:Destroy()
    end
    
    CensuraG.Logger:info("CensuraG framework destroyed")
    _G.CensuraG = nil
end

-- Example usage demonstration
if false then -- Set to true to show examples when loading
    task.spawn(function()
        task.wait(1) -- Wait for everything to initialize
        
        -- Example window
        local demoWindow = CensuraG.Window.new("CensuraG Demo", 100, 100, 400, 300)
        
        -- Add some elements
        CensuraG.TextButton.new(demoWindow, "Open Settings", 10, 10, 120, 30, function()
            CensuraG.OpenSettings()
        })
        
        CensuraG.TextButton.new(demoWindow, "Toggle Theme", 10, 50, 120, 30, function()
            local themes = {"Dark", "Light", "Military"}
            local currentIndex = table.find(themes, CensuraG.Styling.CurrentTheme) or 1
            local nextIndex = (currentIndex % #themes) + 1
            CensuraG.Styling:SetTheme(themes[nextIndex])
        })
        
        CensuraG.Logger:info("Demo window created")
    end)
end

CensuraG.Logger:info("CensuraG initialization completed successfully")
return CensuraG
