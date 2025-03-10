-- Revised init.lua for CensuraG with Oratio integration
local CensuraG = {
    _VERSION = "1.0.0",
    _DESCRIPTION = "Modern UI framework for Roblox exploits",
    _LICENSE = "MIT"
}
_G.CensuraG = CensuraG

-- Central module loader that uses loadstring and caches results.
local ModuleCache = {}

local function loadModule(url, moduleName)
    if ModuleCache[moduleName] then
        return ModuleCache[moduleName]
    end
    local success, response = pcall(function()
        return game:HttpGet(url, true)
    end)
    if not success or not response then
        return nil, "Failed to fetch module [" .. moduleName .. "] from URL: " .. url .. " - " .. tostring(response)
    end
    local moduleFunc, err = loadstring(response)
    if not moduleFunc then
        return nil, "Failed to compile [" .. moduleName .. "]: " .. err
    end
    local success, result = pcall(moduleFunc)
    if not success then
        return nil, "Failed to execute module [" .. moduleName .. "]: " .. result
    end
    ModuleCache[moduleName] = result
    return result
end

-- Base URLs for loading modules
local baseUrl = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/"
local oratioUrl = "https://raw.githubusercontent.com/LxckStxp/Oratio/main/init.lua"

-- Load Oratio first to create our logger.
local Oratio, oratioErr = loadModule(oratioUrl, "Oratio")
if Oratio then
    -- Create the logger using Oratio.new. (Oratio's dependencies are loaded in its init)
    CensuraG.Logger = Oratio.new({
        moduleName = "CensuraG",
        minLevel = "DEBUG",
        storeHistory = true,
        outputEnabled = true
    })
else
    -- Fallback basic logger if Oratio fails.
    CensuraG.Logger = {
        debug = function(...) print("[DEBUG][CensuraG]", ...) end,
        info = function(...) print("[INFO][CensuraG]", ...) end,
        warn = function(...) warn("[WARN][CensuraG]", ...) end,
        error = function(...) warn("[ERROR][CensuraG]", ...) end,
        critical = function(...) warn("[CRITICAL][CensuraG]", ...) end
    }
    CensuraG.Logger:warn("Failed to load Oratio: %s", oratioErr or "Unknown error")
end

CensuraG.Logger:info("Initializing CensuraG v%s", CensuraG._VERSION)

-- List of modules to load in order
local modules = {
    { name = "Utilities", path = "Core/Utilities.lua" },
    { name = "ErrorHandler", path = "Core/ErrorHandler.lua" },
    { name = "EventManager", path = "Core/EventManager.lua" },
    { name = "DependencyManager", path = "Core/DependencyManager.lua" },
    { name = "Styling", path = "Core/Styling.lua" },
    { name = "Animation", path = "Core/Animation.lua" },
    { name = "UIElement", path = "UI/UIElement.lua" },
    { name = "Draggable", path = "UI/Draggable.lua" },
    { name = "WindowManager", path = "UI/WindowManager.lua" },
    { name = "Taskbar", path = "UI/Taskbar.lua" },
    { name = "Window", path = "Elements/Window.lua" },
    { name = "TextButton", path = "Elements/TextButton.lua" },
    { name = "ImageLabel", path = "Elements/ImageLabel.lua" },
    { name = "Slider", path = "Elements/Slider.lua" },
    { name = "Switch", path = "Elements/Switch.lua" },
    { name = "Dropdown", path = "Elements/Dropdown.lua" },
    { name = "Cluster", path = "Elements/Cluster.lua" },
    { name = "Settings", path = "Elements/Settings.lua" }
}

-- Load all modules into CensuraG first
local loadedModules = {}
for _, mod in ipairs(modules) do
    local moduleUrl = baseUrl .. mod.path
    local module, err = loadModule(moduleUrl, mod.name)
    if module then
        CensuraG[mod.name] = module
        loadedModules[mod.name] = module
        CensuraG.Logger:debug("Loaded module: %s", mod.name)
    else
        CensuraG.Logger:error("Failed to load module: %s - %s", mod.name, err or "Unknown error")
    end
end

-- Register modules with DependencyManager if available
if CensuraG.DependencyManager then
    for name, module in pairs(loadedModules) do
        CensuraG.DependencyManager:Register(name, module)
        CensuraG.Logger:debug("Registered module: %s", name)
    end
else
    CensuraG.Logger:warn("DependencyManager not available, skipping module registration")
    -- Create a fallback DependencyManager with no-op functions
    CensuraG.DependencyManager = {
        Register = function() end,
        Get = function(_, name) return loadedModules[name] end,
        HasDependency = function(_, name) return loadedModules[name] ~= nil end,
        ListDependencies = function() return loadedModules end,
        Remove = function() return false end,
        Clear = function() return 0 end,
        RegisterBatch = function() return 0 end
    }
end

-- Initialize the ScreenGui with fallback for external contexts
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    CensuraG.Logger:warn("LocalPlayer not found, attempting to wait...")
    LocalPlayer = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
end
local playerGui = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui", 5)
if not playerGui then
    CensuraG.Logger:warn("PlayerGui not accessible, creating fallback ScreenGui")
    CensuraG.ScreenGui = Instance.new("ScreenGui")
    CensuraG.ScreenGui.Name = "CensuraGGui"
    local coreGui = game:GetService("CoreGui")
    if coreGui then
        CensuraG.ScreenGui.Parent = coreGui
    else
        CensuraG.Logger:error("CoreGui not accessible, ScreenGui creation failed")
        CensuraG.ScreenGui = nil
    end
    if CensuraG.ScreenGui then
        CensuraG.ScreenGui.ResetOnSpawn = false
        CensuraG.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        CensuraG.ScreenGui.IgnoreGuiInset = true
    end
else
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
end
if CensuraG.ScreenGui then
    CensuraG.Logger:info("ScreenGui initialized: %s", CensuraG.ScreenGui.Name)
else
    CensuraG.Logger:error("Failed to initialize ScreenGui")
    return CensuraG
end

-- Initialize managers after all dependencies are loaded
if CensuraG.WindowManager then
    CensuraG.WindowManager:Init()
    CensuraG.Logger:info("WindowManager initialized")
else
    CensuraG.Logger:warn("WindowManager not initialized due to missing dependency")
end

if CensuraG.Taskbar then
    CensuraG.Taskbar:Init()
    CensuraG.Logger:info("Taskbar initialized")
else
    CensuraG.Logger:warn("Taskbar not initialized due to missing dependency")
end

if CensuraG.Settings then
    task.spawn(function()
        wait(0.5)
        CensuraG.Settings:Init()
        CensuraG.Logger:info("Settings menu auto-initialized")
    end)
else
    CensuraG.Logger:warn("Settings module not loaded")
end

CensuraG.Logger:info("CensuraG initialization completed successfully")

-- API for adding custom elements
function CensuraG.AddCustomElement(name, class)
    if not name or not class then
        CensuraG.Logger:warn("Invalid parameters for AddCustomElement: name=%s, class=%s", tostring(name), tostring(class))
        return
    end
    CensuraG[name] = class
    if CensuraG.DependencyManager then
        CensuraG.DependencyManager:Register(name, class)
    end
    CensuraG.Logger:debug("Added custom element: %s", name)
end

function CensuraG.ToggleSettings()
    if CensuraG.Settings then
        CensuraG.Settings:Toggle()
    else
        CensuraG.Logger:warn("Settings module not loaded")
    end
end

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

function CensuraG.Destroy()
    CensuraG.Logger:info("Destroying CensuraG framework...")
    if CensuraG.EventManager then CensuraG.EventManager:DisconnectAll() end
    if CensuraG.WindowManager then CensuraG.WindowManager:Destroy() end
    if CensuraG.Taskbar then CensuraG.Taskbar:Destroy() end
    if CensuraG.ScreenGui then CensuraG.ScreenGui:Destroy() end
    CensuraG.Logger:info("CensuraG framework destroyed")
    _G.CensuraG = nil
end

CensuraG.Logger:info("CensuraG fully initialized")
return CensuraG
