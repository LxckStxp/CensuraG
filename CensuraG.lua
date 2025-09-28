-- CensuraG/CensuraG.lua (revised with Splash Screen integration)
local function safeLoadstring(url, errorMsg)
    local success, result = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if not success then
        return nil, "Failed to fetch: " .. tostring(result)
    end
    
    local loadSuccess, loadResult = pcall(loadstring, result)
    if not loadSuccess then
        return nil, "Failed to compile: " .. tostring(loadResult)
    end
    
    local execSuccess, execResult = pcall(loadResult)
    if not execSuccess then
        return nil, "Failed to execute: " .. tostring(execResult)
    end
    
    return execResult
end

-- Load and initialize splash screen first
local splash
local splashModule, splashError = safeLoadstring("https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/Splash.lua", "Failed to load Splash")
if splashModule then
    splash = splashModule:Show()
else
    warn("Failed to load splash screen: " .. (splashError or "Unknown error"))
end

-- Initialize the library
if splash then splash:UpdateStatus("Loading core libraries...", 0.1) end
local Oratio, oratioError = safeLoadstring("https://raw.githubusercontent.com/LxckStxp/Oratio/main/init.lua", "Failed to load Oratio")
if not Oratio then 
    if splash then splash:Hide() end
    error("Failed to load Oratio: " .. (oratioError or "Unknown error")) 
end

local CensuraG = rawget(_G, "CensuraG") or {}
_G.CensuraG = CensuraG

-- Initialize Logger
CensuraG.Logger = Oratio.new({
    moduleName = "CensuraG",
    minLevel = "INFO",
    separator = "---"
})

CensuraG.Logger:section("CensuraG Initialization")
CensuraG.Logger:info("Starting CensuraG UI API")

-- Create ScreenGui early to ensure it exists
if splash then splash:UpdateStatus("Creating screen container...", 0.15) end
local function createScreenGui()
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local existingGui = playerGui:FindFirstChild("CensuraGScreenGui")
    if existingGui then return existingGui end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CensuraGScreenGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    return screenGui
end

CensuraG.ScreenGui = createScreenGui()
CensuraG.Logger:info("Created ScreenGui container")

-- Load Utilities first
if splash then splash:UpdateStatus("Loading utilities...", 0.2) end
local Utilities, utilitiesError = safeLoadstring("https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/Utilities.lua", "Failed to load Utilities")
if not Utilities then
    CensuraG.Logger:error("Failed to load Utilities: " .. (utilitiesError or "Unknown error"))
    Utilities = {
        LoadModule = function(url)
            CensuraG.Logger:error("Utilities.LoadModule called but Utilities failed to load")
            return nil
        end
    }
end
CensuraG.Utilities = Utilities

-- Load Core Modules with better error handling
if splash then splash:UpdateStatus("Loading core modules...", 0.3) end
local coreModules = {
    Config = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/Config.lua",
    Methods = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/Methods.lua",
    AnimationManager = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/AnimationManager.lua",
    RefreshManager = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/RefreshManager.lua",
    DesktopManager = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/DesktopManager.lua"
}

local allCoreModulesLoaded = true
local moduleCount = 0
for name, url in pairs(coreModules) do
    moduleCount = moduleCount + 1
    if splash then 
        splash:UpdateStatus("Loading " .. name .. "...", 0.3 + (moduleCount / #coreModules) * 0.2) 
    end
    
    local module, error = safeLoadstring(url, "Failed to load " .. name)
    if module then
        CensuraG[name] = module
        CensuraG.Logger:info("Loaded core module: " .. name)
    else
        CensuraG.Logger:error("Failed to load " .. name .. ": " .. (error or "Unknown error"))
        allCoreModulesLoaded = false
    end
end

if not allCoreModulesLoaded then
    CensuraG.Logger:warn("Some core modules failed to load, functionality may be limited")
end

-- Initialize RefreshManager early if it's loaded
if splash then splash:UpdateStatus("Initializing refresh manager...", 0.5) end
if CensuraG.RefreshManager then
    CensuraG.RefreshManager:Initialize()
    CensuraG.Logger:info("RefreshManager initialized")
end

-- Load Components with better error handling
if splash then splash:UpdateStatus("Loading UI components...", 0.55) end
CensuraG.Components = {}
local componentList = {
    "window", "taskbar", "textlabel", "textbutton", "imagelabel", "slider", "dropdown", "switch", "grid", "systemtray"
}

local allComponentsLoaded = true
for i, component in ipairs(componentList) do
    if splash then 
        splash:UpdateStatus("Loading component: " .. component, 0.55 + (i / #componentList) * 0.2) 
    end
    
    local url = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/components/" .. component .. ".lua"
    local loadedComponent = Utilities.LoadModule(url)
    if loadedComponent then
        CensuraG.Components[component] = loadedComponent
        CensuraG.Logger:info("Loaded component: " .. component)
    else
        CensuraG.Logger:error("Failed to load component: " .. component)
        allComponentsLoaded = false
    end
end

if not allComponentsLoaded then
    CensuraG.Logger:warn("Some components failed to load, UI functionality may be limited")
end

-- Wait to load managers after components
if allComponentsLoaded then
    -- Load manager modules that depend on components
    if splash then splash:UpdateStatus("Loading managers...", 0.75) end
    local managerModules = {
        WindowManager = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/WindowManager.lua",
        TaskbarManager = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/TaskbarManager.lua"
    }
    
    local allManagersLoaded = true
    local managerCount = 0
    for name, url in pairs(managerModules) do
        managerCount = managerCount + 1
        if splash then 
            splash:UpdateStatus("Loading " .. name .. "...", 0.75 + (managerCount / #managerModules) * 0.1) 
        end
        
        local module, error = safeLoadstring(url, "Failed to load " .. name)
        if module then
            CensuraG[name] = module
            CensuraG.Logger:info("Loaded manager: " .. name)
        else
            CensuraG.Logger:error("Failed to load " .. name .. ": " .. (error or "Unknown error"))
            allManagersLoaded = false
        end
    end
    
    if not allManagersLoaded then
        CensuraG.Logger:warn("Some managers failed to load, functionality may be limited")
    end
    
    -- Initialize global state
    if splash then splash:UpdateStatus("Initializing global state...", 0.85) end
    CensuraG.Windows = CensuraG.Windows or {}
    CensuraG.Taskbar = CensuraG.Taskbar or nil
    
    -- Initialize Taskbar only if TaskbarManager loaded
    if splash then splash:UpdateStatus("Initializing taskbar...", 0.9) end
    if CensuraG.TaskbarManager and not CensuraG.Taskbar then
        pcall(function()
            CensuraG.Taskbar = { Instance = CensuraG.TaskbarManager }
            
            -- Safely initialize the taskbar
            if CensuraG.Taskbar.Instance and typeof(CensuraG.Taskbar.Instance) == "table" and CensuraG.Taskbar.Instance.Initialize then
                CensuraG.Taskbar.Instance:Initialize()
                CensuraG.Logger:info("Taskbar initialized")
                
                -- Initialize SystemTray after Taskbar
                if splash then splash:UpdateStatus("Initializing system tray...", 0.93) end
                if CensuraG.Components.systemtray and not CensuraG.SystemTray then
                    CensuraG.SystemTray = CensuraG.Components.systemtray(CensuraG.Taskbar.Instance.Frame)
                    CensuraG.Logger:info("SystemTray initialized")
                end
            else
                CensuraG.Logger:error("TaskbarManager invalid or Initialize method missing")
            end
        end)
    end
    
    -- Initialize Desktop Manager
    if splash then splash:UpdateStatus("Initializing desktop environment...", 0.95) end
    if CensuraG.DesktopManager then
        pcall(function()
            CensuraG.Desktop = CensuraG.DesktopManager
            CensuraG.Desktop:Initialize()
            CensuraG.Logger:info("Desktop environment initialized")
        end)
    else
        CensuraG.Logger:warn("DesktopManager not loaded, desktop features disabled")
    end
else
    CensuraG.Logger:error("Not initializing managers due to missing components")
end

-- Add utility methods to CensuraG
if splash then splash:UpdateStatus("Setting up API methods...", 0.98) end

CensuraG.CreateWindow = function(title)
    if CensuraG.Methods and CensuraG.Methods.CreateWindow then
        local window = CensuraG.Methods:CreateWindow(title)
        if window then
            -- Automatically bring new windows to front
            window:BringToFront()
        end
        return window
    else
        CensuraG.Logger:error("Methods module not loaded, cannot create window")
        return nil
    end
end

CensuraG.SetTheme = function(themeName)
    if CensuraG.Config then
        -- Store the original theme name for logging
        local oldTheme = CensuraG.Config.CurrentTheme
        
        -- Update the theme
        CensuraG.Config.CurrentTheme = themeName
        
        -- Refresh all UI elements using RefreshManager if available
        if CensuraG.RefreshManager then
            CensuraG.RefreshManager:RefreshAll()
            if CensuraG.SystemTray then
                CensuraG.SystemTray:Refresh()
            end
            CensuraG.Logger:info("Theme changed from " .. oldTheme .. " to " .. themeName .. " (using RefreshManager)")
        -- Fall back to Methods if RefreshManager isn't available
        elseif CensuraG.Methods and CensuraG.Methods.RefreshAll then
            CensuraG.Methods:RefreshAll()
            if CensuraG.SystemTray then
                CensuraG.SystemTray:Refresh()
            end
            CensuraG.Logger:info("Theme changed from " .. oldTheme .. " to " .. themeName .. " (using Methods)")
        else
            CensuraG.Logger:warn("Theme changed to " .. themeName .. " but no refresh mechanism available")
        end
    else
        CensuraG.Logger:error("Config module not loaded, cannot change theme")
    end
end

-- Add refresh utility methods that use RefreshManager
CensuraG.RefreshComponent = function(component, instance)
    if CensuraG.RefreshManager then
        CensuraG.RefreshManager:RefreshComponent(component, instance)
    elseif CensuraG.Methods and CensuraG.Methods.RefreshComponent then
        CensuraG.Methods:RefreshComponent(component, instance)
    else
        CensuraG.Logger:error("No refresh mechanism available, cannot refresh component")
    end
end

CensuraG.RefreshAll = function()
    if CensuraG.RefreshManager then
        CensuraG.RefreshManager:RefreshAll()
        if CensuraG.SystemTray then
            CensuraG.SystemTray:Refresh()
        end
        if CensuraG.Desktop then
            CensuraG.Desktop:Refresh()
        end
    elseif CensuraG.Methods and CensuraG.Methods.RefreshAll then
        CensuraG.Methods:RefreshAll()
        if CensuraG.SystemTray then
            CensuraG.SystemTray:Refresh()
        end
        if CensuraG.Desktop then
            CensuraG.Desktop:Refresh()
        end
    else
        CensuraG.Logger:error("No refresh mechanism available, cannot refresh all components")
    end
end

-- Desktop Management Functions
CensuraG.TileWindows = function()
    if CensuraG.WindowManager then
        CensuraG.WindowManager.TileWindows()
    else
        CensuraG.Logger:error("WindowManager not available")
    end
end

CensuraG.CascadeWindows = function()
    if CensuraG.WindowManager then
        CensuraG.WindowManager.CascadeWindows()
    else
        CensuraG.Logger:error("WindowManager not available")
    end
end

CensuraG.CloseAllWindows = function()
    if CensuraG.WindowManager then
        CensuraG.WindowManager.CloseAllWindows()
    else
        CensuraG.Logger:error("WindowManager not available")
    end
end

CensuraG.GetActiveWindow = function()
    if CensuraG.WindowManager then
        return CensuraG.WindowManager.GetActiveWindow()
    end
    return nil
end

CensuraG.CreateDesktopIcon = function(name, iconId, callback)
    if CensuraG.Desktop then
        return CensuraG.Desktop:CreateDesktopIcon(name, iconId, callback)
    else
        CensuraG.Logger:error("Desktop not initialized")
        return nil
    end
end

-- Hide splash screen and complete initialization
if splash then 
    splash:UpdateStatus("Ready!", 1.0)
    task.delay(0.5, function()
        splash:Hide()
    end)
end

--loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura-Applications/main/Services/Remote.lua"))() -- Debug Tool

CensuraG.Logger:info("CensuraG initialization complete")
return CensuraG
