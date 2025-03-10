-- Revised init.lua for CensuraG with Oratio and ZIndexManager integration
local CensuraG = {
    _VERSION = "1.0.1", -- Updated version to reflect enhancements
    _DESCRIPTION = "Modern UI framework for Roblox exploits",
    _LICENSE = "MIT"
}
_G.CensuraG = CensuraG

-- Central module loader with caching
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

-- Load Oratio first for logging
local Oratio, oratioErr = loadModule(oratioUrl, "Oratio")
if Oratio then
    CensuraG.Logger = Oratio.new({
        moduleName = "CensuraG",
        minLevel = "DEBUG",
        storeHistory = true,
        outputEnabled = true
    })
else
    CensuraG.Logger = {
        debug = function(...) print("[DEBUG][CensuraG]", ...) end,
        info = function(...) print("[INFO][CensuraG]", ...) end,
        warn = function(...) warn("[WARN][CensuraG]", ...) end,
        error = function(...) warn("[ERROR][CensuraG]", ...) end,
        critical = function(...) warn("[CRITICAL][CensuraG]", ...) end
    }
    CensuraG.Logger:error("Failed to load Oratio: %s", oratioErr or "Unknown error")
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
    { name = "ZIndexManager", path = "Core/ZIndexManager.lua" }, -- Added ZIndexManager
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

-- Load all modules into CensuraG
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

-- Register modules with DependencyManager
if CensuraG.DependencyManager then
    for name, module in pairs(loadedModules) do
        CensuraG.DependencyManager:Register(name, module)
        CensuraG.Logger:debug("Registered module: %s", name)
    end
else
    CensuraG.Logger:warn("DependencyManager not available, using fallback")
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

-- Initialize ScreenGui with fallback
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
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
    CensuraG.ScreenGui = playerGui:FindFirstChild("CensuraGGui") or CensuraG.Utilities.createInstance("ScreenGui", {
        Parent = playerGui,
        Name = "CensuraGGui",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true
    })
end
if not CensuraG.ScreenGui then
    CensuraG.Logger:critical("Failed to initialize ScreenGui, aborting initialization")
    return CensuraG
end
CensuraG.Logger:info("ScreenGui initialized: %s", CensuraG.ScreenGui.Name)

-- Initialize managers in order
local function initializeManagers()
    if CensuraG.ZIndexManager then
        CensuraG.ZIndexManager:Init()
        CensuraG.Logger:info("ZIndexManager initialized")
    else
        CensuraG.Logger:error("ZIndexManager not loaded, critical functionality may be impaired")
    end

    if CensuraG.WindowManager then
        CensuraG.WindowManager:Init()
        CensuraG.Logger:info("WindowManager initialized")
    else
        CensuraG.Logger:error("WindowManager not initialized due to missing dependency")
    end

    if CensuraG.Taskbar then
        CensuraG.Taskbar:Init()
        CensuraG.Logger:info("Taskbar initialized")
    else
        CensuraG.Logger:warn("Taskbar not initialized due to missing dependency")
    end

    if CensuraG.Settings then
        task.spawn(function()
            wait(0.5) -- Delay to ensure UI is ready
            CensuraG.Settings:Init()
            CensuraG.Logger:info("Settings menu auto-initialized")
        end)
    else
        CensuraG.Logger:warn("Settings module not loaded")
    end
end

initializeManagers()

-- Verify critical components
local criticalComponents = {"Utilities", "EventManager", "WindowManager", "ZIndexManager"}
for _, component in ipairs(criticalComponents) do
    if not CensuraG[component] then
        CensuraG.Logger:critical("Critical component %s not loaded, framework may be unstable", component)
    end
end

CensuraG.Logger:info("CensuraG initialization completed successfully")

-- Public API
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

-- Cleanup and destroy
function CensuraG.Destroy()
    CensuraG.Logger:info("Destroying CensuraG framework...")
    if CensuraG.EventManager then
        CensuraG.EventManager:DisconnectAll()
        CensuraG.Logger:debug("Disconnected all events")
    end
    if CensuraG.WindowManager then
        CensuraG.WindowManager:Destroy()
        CensuraG.Logger:debug("WindowManager destroyed")
    end
    if CensuraG.Taskbar then
        CensuraG.Taskbar:Destroy()
        CensuraG.Logger:debug("Taskbar destroyed")
    end
    if CensuraG.ZIndexManager then
        CensuraG.ZIndexManager:Cleanup()
        CensuraG.Logger:debug("ZIndexManager cleaned up")
    end
    if CensuraG.ScreenGui then
        CensuraG.ScreenGui:Destroy()
        CensuraG.Logger:debug("ScreenGui destroyed")
    end
    ModuleCache = {}
    CensuraG.Logger:info("CensuraG framework destroyed")
    _G.CensuraG = nil
end

CensuraG.Logger:info("CensuraG fully initialized")
return CensuraG
