-- Revised init.lua for CensuraG with improved module loading and organization
local CensuraG = {
    _VERSION = "1.0.0",
    _DESCRIPTION = "Modern UI framework for Roblox exploits",
    _LICENSE = "MIT"
}
_G.CensuraG = CensuraG

-- =============================================
-- Module Loading System
-- =============================================
local ModuleCache = {}

-- Helper function to load a module from URL
local function loadModule(url, moduleName)
    -- Return cached module if available
    if ModuleCache[moduleName] then
        return ModuleCache[moduleName]
    end
    
    -- Fetch module content
    local success, response = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if not success or not response then
        return nil, "Failed to fetch module [" .. moduleName .. "]: " .. tostring(response)
    end
    
    -- Compile module
    local moduleFunc, err = loadstring(response)
    if not moduleFunc then
        return nil, "Failed to compile [" .. moduleName .. "]: " .. err
    end
    
    -- Execute module
    local success, result = pcall(moduleFunc)
    if not success then
        return nil, "Failed to execute [" .. moduleName .. "]: " .. result
    end
    
    -- Cache and return the result
    ModuleCache[moduleName] = result
    return result
end

-- Helper to load and register a CensuraG module
local function loadCensuraModule(name, path, baseUrl)
    local moduleUrl = baseUrl .. path
    local module, err = loadModule(moduleUrl, name)
    
    if module then
        CensuraG[name] = module
        return true
    else
        if CensuraG.Logger then
            CensuraG.Logger:error("Failed to load module: %s - %s", name, err or "Unknown error")
        else
            warn("Failed to load module: " .. name .. " - " .. (err or "Unknown error"))
        end
        return false
    end
end

-- Base URLs for loading modules
local baseUrl = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/"
local oratioUrl = "https://raw.githubusercontent.com/LxckStxp/Oratio/main/init.lua"

-- =============================================
-- Logger Initialization
-- =============================================
-- Load Oratio first to create our logger
local Oratio, oratioErr = loadModule(oratioUrl, "Oratio")
if Oratio then
    CensuraG.Logger = Oratio.new({
        moduleName = "CensuraG",
        minLevel = "INFO", -- Default to INFO, updated by Config later
        storeHistory = true,
        outputEnabled = true
    })
else
    -- Create fallback logger if Oratio fails to load
    CensuraG.Logger = {
        debug = function(...) print("[DEBUG][CensuraG]", ...) end,
        info = function(...) print("[INFO][CensuraG]", ...) end,
        warn = function(...) warn("[WARN][CensuraG]", ...) end,
        error = function(...) warn("[ERROR][CensuraG]", ...) end,
        critical = function(...) warn("[CRITICAL][CensuraG]", ...) end,
        LOG_LEVELS = { DEBUG = 1, INFO = 2, WARN = 3, ERROR = 4, CRITICAL = 5 },
        minLevel = 2,
        setMinLevel = function(self, level) self.minLevel = self.LOG_LEVELS[level] or 2 end
    }
    
    -- Log the failure
    CensuraG.Logger:warn("Failed to load Oratio: %s", oratioErr or "Unknown error")
end

CensuraG.Logger:info("Initializing CensuraG v%s", CensuraG._VERSION)

-- =============================================
-- Configuration
-- =============================================
-- Initialize Config as the single source of truth
CensuraG.Config = {
    EnableShadows = true,
    AnimationQuality = 1.0,
    AnimationSpeed = 1.0,
    WindowSnapEnabled = true,
    DebugMode = false,
    AutoHide = true,
    Theme = "Dark",
    WindowTransparency = 0.2
}

-- Apply initial DebugMode to logger
CensuraG.Logger:setMinLevel(CensuraG.Config.DebugMode and "DEBUG" or "INFO")

-- =============================================
-- Module Definitions
-- =============================================
-- Core modules (load order matters)
local coreModules = {
    { name = "Utilities", path = "Core/Utilities.lua" },
    { name = "ErrorHandler", path = "Core/ErrorHandler.lua" },
    { name = "EventManager", path = "Core/EventManager.lua" },
    { name = "DependencyManager", path = "Core/DependencyManager.lua" },
    { name = "Styling", path = "Core/Styling.lua" },
    { name = "Animation", path = "Core/Animation.lua" }
}

-- UI infrastructure modules
local uiModules = {
    { name = "UIElement", path = "UI/UIElement.lua" },
    { name = "Draggable", path = "UI/Draggable.lua" },
    { name = "WindowManager", path = "UI/WindowManager.lua" },
    { name = "Taskbar", path = "UI/Taskbar.lua" }
}

-- UI element modules
local elementModules = {
    { name = "Window", path = "Elements/Window.lua" },
    { name = "TextButton", path = "Elements/TextButton.lua" },
    { name = "ImageLabel", path = "Elements/ImageLabel.lua" },
    { name = "Slider", path = "Elements/Slider.lua" },
    { name = "Switch", path = "Elements/Switch.lua" },
    { name = "Dropdown", path = "Elements/Dropdown.lua" },
    { name = "Cluster", path = "Elements/Cluster.lua" },
    { name = "Settings", path = "Elements/Settings.lua" }
}

-- =============================================
-- Module Loading
-- =============================================
local loadedModules = {}

-- Load core modules first
CensuraG.Logger:info("Loading core modules...")
for _, mod in ipairs(coreModules) do
    local success = loadCensuraModule(mod.name, mod.path, baseUrl)
    if success then
        loadedModules[mod.name] = CensuraG[mod.name]
        CensuraG.Logger:debug("Loaded core module: %s", mod.name)
    end
end

-- Load UI infrastructure modules
CensuraG.Logger:info("Loading UI infrastructure modules...")
for _, mod in ipairs(uiModules) do
    local success = loadCensuraModule(mod.name, mod.path, baseUrl)
    if success then
        loadedModules[mod.name] = CensuraG[mod.name]
        CensuraG.Logger:debug("Loaded UI module: %s", mod.name)
    end
end

-- Load UI element modules
CensuraG.Logger:info("Loading UI element modules...")
for _, mod in ipairs(elementModules) do
    local success = loadCensuraModule(mod.name, mod.path, baseUrl)
    if success then
        loadedModules[mod.name] = CensuraG[mod.name]
        CensuraG.Logger:debug("Loaded UI element: %s", mod.name)
    end
end

-- =============================================
-- Dependency Registration
-- =============================================
-- Register modules with DependencyManager if available
if CensuraG.DependencyManager then
    CensuraG.Logger:info("Registering modules with DependencyManager...")
    for name, module in pairs(loadedModules) do
        CensuraG.DependencyManager:Register(name, module)
    end
else
    CensuraG.Logger:warn("DependencyManager not available, creating fallback")
    -- Create fallback DependencyManager
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

-- =============================================
-- ScreenGui Initialization
-- =============================================
CensuraG.Logger:info("Initializing ScreenGui...")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Wait for LocalPlayer if needed
if not LocalPlayer then
    CensuraG.Logger:warn("LocalPlayer not found, attempting to wait...")
    LocalPlayer = Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
end

local playerGui = LocalPlayer and LocalPlayer:WaitForChild("PlayerGui", 5)

-- Create ScreenGui based on available context
if not playerGui then
    CensuraG.Logger:warn("PlayerGui not accessible, creating fallback ScreenGui")
    
    -- Try to use CoreGui
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
    -- Use PlayerGui
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

-- Verify ScreenGui was created
if CensuraG.ScreenGui then
    CensuraG.Logger:info("ScreenGui initialized: %s", CensuraG.ScreenGui.Name)
else
    CensuraG.Logger:error("Failed to initialize ScreenGui")
    return CensuraG
end

-- =============================================
-- Manager Initialization
-- =============================================
-- Initialize WindowManager
if CensuraG.WindowManager then
    CensuraG.WindowManager:Init()
    CensuraG.Logger:info("WindowManager initialized")
else
    CensuraG.Logger:warn("WindowManager not initialized due to missing dependency")
end

-- Initialize Taskbar
if CensuraG.Taskbar then
    CensuraG.Taskbar:Init()
    CensuraG.Logger:info("Taskbar initialized")
else
    CensuraG.Logger:warn("Taskbar not initialized due to missing dependency")
end

-- Initialize Settings
if CensuraG.Settings then
    task.spawn(function()
        wait(0.5) -- Give a moment for everything else to initialize
        CensuraG.Settings:Init()
        CensuraG.Logger:info("Settings menu auto-initialized")
    end)
else
    CensuraG.Logger:warn("Settings module not loaded")
end

-- =============================================
-- Public API
-- =============================================
-- Add custom element to the framework
function CensuraG.AddCustomElement(name, class)
    if not name or not class then
        CensuraG.Logger:warn("Invalid parameters for AddCustomElement: name=%s, class=%s", 
            tostring(name), tostring(class))
        return
    end
    
    CensuraG[name] = class
    
    if CensuraG.DependencyManager then
        CensuraG.DependencyManager:Register(name, class)
    end
    
    CensuraG.Logger:debug("Added custom element: %s", name)
end

-- Toggle settings window
function CensuraG.ToggleSettings()
    if CensuraG.Settings then
        CensuraG.Settings:Toggle()
    else
        CensuraG.Logger:warn("Settings module not loaded")
    end
end

-- Open settings window
function CensuraG.OpenSettings()
    if CensuraG.Settings then
        CensuraG.Settings:Show()
    else
        CensuraG.Logger:warn("Settings module not loaded")
    end
end

-- Clean shutdown of the framework
function CensuraG.Destroy()
    CensuraG.Logger:info("Destroying CensuraG framework...")
    
    -- Disconnect events
    if CensuraG.EventManager then 
        CensuraG.EventManager:DisconnectAll() 
    end
    
    -- Destroy managers
    if CensuraG.WindowManager then 
        CensuraG.WindowManager:Destroy() 
    end
    
    if CensuraG.Taskbar then 
        CensuraG.Taskbar:Destroy() 
    end
    
    -- Remove ScreenGui
    if CensuraG.ScreenGui then 
        CensuraG.ScreenGui:Destroy() 
    end
    
    CensuraG.Logger:info("CensuraG framework destroyed")
    _G.CensuraG = nil
end

-- =============================================
-- Initialization Complete
-- =============================================
CensuraG.Logger:info("CensuraG initialization complete")
return CensuraG
