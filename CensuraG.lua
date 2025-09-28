-- CensuraG/CensuraG.lua (Modern Glassmorphic Desktop Environment v2.0)
-- High-performance, streamlined initialization with advanced error recovery

-- Singleton Pattern - Ensure single instance per session
if rawget(_G, "CensuraG") and _G.CensuraG.Initialized then
    local existing = _G.CensuraG
    existing.Logger:info("Accessing existing CensuraG session")
    
    -- Handle pending app registration gracefully
    if _G.CensuraGPendingApp then
        local app = _G.CensuraGPendingApp
        task.spawn(function()
            existing:RegisterApp(app.Name, app.Description, app.Icon, app.Callback, app.Category)
        end)
        _G.CensuraGPendingApp = nil
    end
    
    -- Restore focus to existing session
    if existing.BringToFront then
        existing:BringToFront()
    end
    
    return existing
end

-- Performance tracking
local initStartTime = tick()
local sessionId = tostring(math.random(100000, 999999)) .. "_" .. math.floor(initStartTime)
rawset(_G, "CensuraGSessionId", sessionId)

-- Advanced module loading system with retry logic and caching
local ModuleLoader = {}
ModuleLoader.cache = {}
ModuleLoader.retryAttempts = 3
ModuleLoader.retryDelay = 0.5

function ModuleLoader:LoadModule(url, name, required)
    -- Check cache first
    if self.cache[url] then
        return self.cache[url], nil
    end
    
    local attempts = 0
    local lastError = ""
    
    while attempts < self.retryAttempts do
        attempts = attempts + 1
        
        local success, result = pcall(function()
            local source = game:HttpGet(url, true)
            local compiled = loadstring(source)
            if not compiled then
                error("Failed to compile module")
            end
            return compiled()
        end)
        
        if success then
            -- Cache successful load
            self.cache[url] = result
            return result, nil
        else
            lastError = tostring(result)
            if attempts < self.retryAttempts then
                task.wait(self.retryDelay * attempts) -- Exponential backoff
            end
        end
    end
    
    return nil, string.format("Failed to load %s after %d attempts. Last error: %s", 
                             name or "module", attempts, lastError)
end

-- Initialize CensuraG core
local CensuraG = rawget(_G, "CensuraG") or {
    -- Performance tracking
    InitTime = initStartTime,
    SessionId = sessionId,
    Version = "2.0.0",
    BuildNumber = math.floor(tick()),
    
    -- State management
    Initialized = false,
    Loading = true,
    
    -- Component registry
    Components = {},
    Managers = {},
    Windows = {},
    
    -- API surface
    API = {}
}
_G.CensuraG = CensuraG

-- Load splash screen with fallback
local splash
local splashModule, splashError = ModuleLoader:LoadModule(
    "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/Splash.lua",
    "Splash", false
)

if splashModule then
    splash = splashModule:Show()
else
    -- Minimal fallback splash
    warn("Splash screen failed to load, using fallback: " .. (splashError or "Unknown"))
    splash = {
        UpdateStatus = function(_, text, progress) 
            print(string.format("[CensuraG] %s (%.0f%%)", text or "Loading...", (progress or 0) * 100))
        end,
        Hide = function() end
    }
end

-- Load essential dependencies
if splash then splash:UpdateStatus("Loading essential services...", 0.05) end

-- Oratio Logger (Critical dependency)
local Oratio, oratioError = ModuleLoader:LoadModule(
    "https://raw.githubusercontent.com/LxckStxp/Oratio/main/init.lua", 
    "Oratio", true
)

if not Oratio then 
    if splash then splash:Hide() end
    error("Critical dependency failed: " .. (oratioError or "Unknown error"))
end

-- Initialize high-performance logger
CensuraG.Logger = Oratio.new({
    moduleName = "CensuraG v" .. CensuraG.Version,
    minLevel = "DEBUG",
    separator = "═══",
    enableColors = true,
    timestampFormat = "[%H:%M:%S]"
})

CensuraG.Logger:section("CensuraG Modern Initialization")
CensuraG.Logger:info("Session: " .. sessionId)
CensuraG.Logger:debug("Init performance tracking started")

-- Create optimized ScreenGui container
if splash then splash:UpdateStatus("Creating display container...", 0.1) end

CensuraG.ScreenGui = (function()
    local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    local existing = playerGui:FindFirstChild("CensuraGScreenGui")
    if existing then 
        CensuraG.Logger:debug("Reusing existing ScreenGui")
        return existing 
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "CensuraGScreenGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 100 -- Ensure proper layering
    screenGui.Parent = playerGui
    
    CensuraG.Logger:debug("Created new ScreenGui container")
    return screenGui
end)()

-- Parallel loading system for core modules
if splash then splash:UpdateStatus("Loading core architecture...", 0.15) end

local CoreLoader = {}
CoreLoader.modules = {
    -- Critical path modules (load sequentially)
    {
        name = "Config",
        url = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/Config.lua",
        critical = true
    },
    {
        name = "Utilities", 
        url = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/Utilities.lua",
        critical = true
    },
    -- Non-critical modules (can load in parallel)
    {
        name = "Methods",
        url = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/Methods.lua",
        critical = false
    },
    {
        name = "AnimationManager",
        url = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/AnimationManager.lua",
        critical = false
    },
    {
        name = "RefreshManager",
        url = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/RefreshManager.lua",
        critical = false
    }
}

-- Load critical modules first
for i, moduleInfo in ipairs(CoreLoader.modules) do
    if moduleInfo.critical then
        if splash then 
            splash:UpdateStatus("Loading " .. moduleInfo.name .. "...", 0.15 + (i * 0.05))
        end
        
        local module, error = ModuleLoader:LoadModule(moduleInfo.url, moduleInfo.name, true)
        if module then
            CensuraG[moduleInfo.name] = module
            CensuraG.Logger:info("✓ Loaded critical module: " .. moduleInfo.name)
        else
            CensuraG.Logger:error("✗ Critical module failed: " .. moduleInfo.name .. " - " .. error)
            if splash then splash:Hide() end
            error("Critical module failure: " .. moduleInfo.name)
        end
    end
end

-- Initialize Config early for theme support
if CensuraG.Config then
    -- Ensure Config is properly initialized
    if type(CensuraG.Config.Initialize) == "function" then
        CensuraG.Config:Initialize()
    end
    CensuraG.Logger:info("Configuration system ready - Theme: " .. (CensuraG.Config.CurrentTheme or "Default"))
end

-- Load non-critical modules in parallel (simulate with coroutines)
if splash then splash:UpdateStatus("Loading supporting systems...", 0.35) end

local parallelTasks = {}
for i, moduleInfo in ipairs(CoreLoader.modules) do
    if not moduleInfo.critical then
        table.insert(parallelTasks, function()
            local module, error = ModuleLoader:LoadModule(moduleInfo.url, moduleInfo.name, false)
            if module then
                CensuraG[moduleInfo.name] = module
                CensuraG.Logger:info("✓ Loaded module: " .. moduleInfo.name)
            else
                CensuraG.Logger:warn("⚠ Optional module failed: " .. moduleInfo.name .. " - " .. error)
            end
        end)
    end
end

-- Execute parallel tasks
for _, task in ipairs(parallelTasks) do
    task.spawn(task)
end

-- Wait a moment for parallel tasks to complete
task.wait(0.2)

-- Initialize loaded managers
if splash then splash:UpdateStatus("Initializing managers...", 0.5) end
if CensuraG.RefreshManager and type(CensuraG.RefreshManager.Initialize) == "function" then
    CensuraG.RefreshManager:Initialize()
    CensuraG.Logger:info("✓ RefreshManager initialized")
end

if CensuraG.AnimationManager and type(CensuraG.AnimationManager.Initialize) == "function" then
    CensuraG.AnimationManager:Initialize()
    CensuraG.Logger:info("✓ AnimationManager initialized")
end

-- Advanced parallel component loading system
if splash then splash:UpdateStatus("Loading UI components...", 0.55) end

local ComponentLoader = {}
ComponentLoader.components = {
    -- Essential UI components
    {name = "window", priority = "high"},
    {name = "textbutton", priority = "high"},
    {name = "textlabel", priority = "high"},
    
    -- Interactive components
    {name = "slider", priority = "medium"},
    {name = "dropdown", priority = "medium"},
    {name = "switch", priority = "medium"},
    
    -- Advanced components
    {name = "taskbar", priority = "medium"},
    {name = "systemtray", priority = "low"},
    {name = "imagelabel", priority = "low"},
    {name = "grid", priority = "low"}
}

-- Parallel component loading
local componentTasks = {}
local componentResults = {}
local componentsLoaded = 0
local totalComponents = #ComponentLoader.components

for i, comp in ipairs(ComponentLoader.components) do
    task.spawn(function()
        local url = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/components/" .. comp.name .. ".lua"
        
        local module, error
        if CensuraG.Utilities and CensuraG.Utilities.LoadModule then
            module = CensuraG.Utilities.LoadModule(url)
            if not module then error = "Utilities.LoadModule failed" end
        else
            module, error = ModuleLoader:LoadModule(url, comp.name, comp.priority == "high")
        end
        
        componentResults[comp.name] = {
            module = module,
            error = error,
            priority = comp.priority
        }
        
        componentsLoaded = componentsLoaded + 1
        
        if splash then 
            splash:UpdateStatus(
                string.format("Loading components (%d/%d)...", componentsLoaded, totalComponents), 
                0.55 + (componentsLoaded / totalComponents) * 0.15
            )
        end
    end)
end

-- Wait for component loading to complete
while componentsLoaded < totalComponents do
    task.wait(0.01)
end

-- Process component results
CensuraG.Components = {}
local criticalComponentsOK = true
local totalLoadedComponents = 0

for name, result in pairs(componentResults) do
    if result.module then
        CensuraG.Components[name] = result.module
        totalLoadedComponents = totalLoadedComponents + 1
        CensuraG.Logger:info("✓ Component loaded: " .. name .. " (" .. result.priority .. ")")
    else
        if result.priority == "high" then
            criticalComponentsOK = false
            CensuraG.Logger:error("✗ Critical component failed: " .. name .. " - " .. (result.error or "Unknown"))
        else
            CensuraG.Logger:warn("⚠ Optional component failed: " .. name .. " - " .. (result.error or "Unknown"))
        end
    end
end

CensuraG.Logger:info(string.format("Component loading complete: %d/%d loaded", totalLoadedComponents, totalComponents))

-- Load advanced managers (requires components)
if criticalComponentsOK then
    if splash then splash:UpdateStatus("Loading advanced managers...", 0.75) end
    
    local advancedManagers = {
        {
            name = "WindowManager",
            url = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/WindowManager.lua"
        },
        {
            name = "TaskbarManager", 
            url = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/TaskbarManager.lua"
        },
        {
            name = "DesktopManager",
            url = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/DesktopManager.lua"
        }
    }
    
    for i, manager in ipairs(advancedManagers) do
        if splash then 
            splash:UpdateStatus("Loading " .. manager.name .. "...", 0.75 + (i / #advancedManagers) * 0.1)
        end
        
        local module, error = ModuleLoader:LoadModule(manager.url, manager.name, false)
        if module then
            CensuraG[manager.name] = module
            CensuraG.Managers[manager.name] = module
            CensuraG.Logger:info("✓ Manager loaded: " .. manager.name)
        else
            CensuraG.Logger:warn("⚠ Manager failed: " .. manager.name .. " - " .. error)
        end
    end
else
    CensuraG.Logger:error("Skipping manager initialization due to critical component failures")
end

-- Advanced initialization sequence
if splash then splash:UpdateStatus("Initializing desktop environment...", 0.85) end

-- Create modern API surface
CensuraG.API = {
    -- Window management
    CreateWindow = function(config)
        if CensuraG.WindowManager then
            return CensuraG.WindowManager:Create(config)
        end
        CensuraG.Logger:error("WindowManager not available")
        return nil
    end,
    
    -- Theme management  
    SetTheme = function(themeName)
        if CensuraG.Config then
            CensuraG.Config:SetTheme(themeName)
            if CensuraG.RefreshManager then
                CensuraG.RefreshManager:RefreshAll()
            end
            CensuraG.Logger:info("Theme changed to: " .. themeName)
        end
    end,
    
    -- App registration
    RegisterApp = function(appConfig)
        if CensuraG.Desktop then
            return CensuraG.Desktop:RegisterApp(appConfig)
        else
            -- Queue for later registration
            _G.CensuraGPendingApp = appConfig
            return nil
        end
    end,
    
    -- System utilities
    RefreshAll = function()
        if CensuraG.RefreshManager then
            CensuraG.RefreshManager:RefreshAll()
        end
    end
}

-- Initialize core systems
local function initializeSystem()
    local startTime = tick()
    
    -- Initialize TaskbarManager
    if CensuraG.TaskbarManager then
        if splash then splash:UpdateStatus("Starting taskbar...", 0.88) end
        local success, taskbar = pcall(function()
            return CensuraG.TaskbarManager:Initialize()
        end)
        
        if success then
            CensuraG.Taskbar = taskbar
            CensuraG.Logger:info("✓ Taskbar system ready")
            
            -- Initialize SystemTray
            if CensuraG.Components.systemtray then
                CensuraG.SystemTray = CensuraG.Components.systemtray(taskbar.Frame)
                CensuraG.Logger:info("✓ System tray ready")
            end
        else
            CensuraG.Logger:error("✗ Taskbar initialization failed")
        end
    end
    
    -- Initialize DesktopManager  
    if CensuraG.DesktopManager then
        if splash then splash:UpdateStatus("Starting desktop...", 0.92) end
        local success, result = pcall(function()
            CensuraG.Desktop = CensuraG.DesktopManager
            return CensuraG.Desktop:Initialize()
        end)
        
        if success then
            CensuraG.Logger:info("✓ Desktop environment ready")
        else
            CensuraG.Logger:error("✗ Desktop initialization failed: " .. tostring(result))
        end
    end
    
    local initDuration = tick() - startTime
    CensuraG.Logger:debug("System initialization took: " .. string.format("%.2f", initDuration) .. "ms")
end

-- Execute system initialization
pcall(initializeSystem)

-- Finalize API surface and legacy compatibility
if splash then splash:UpdateStatus("Finalizing API surface...", 0.95) end

-- Legacy compatibility methods
CensuraG.CreateWindow = CensuraG.API.CreateWindow
CensuraG.SetTheme = CensuraG.API.SetTheme
CensuraG.RegisterApp = CensuraG.API.RegisterApp
CensuraG.RefreshAll = CensuraG.API.RefreshAll

-- Extended desktop management
CensuraG.TileWindows = function()
    if CensuraG.WindowManager and CensuraG.WindowManager.TileWindows then
        return CensuraG.WindowManager:TileWindows()
    end
    CensuraG.Logger:warn("Window tiling not available")
end

CensuraG.CascadeWindows = function()
    if CensuraG.WindowManager and CensuraG.WindowManager.CascadeWindows then
        return CensuraG.WindowManager:CascadeWindows()  
    end
    CensuraG.Logger:warn("Window cascading not available")
end

CensuraG.BringToFront = function()
    if CensuraG.Desktop and CensuraG.Desktop.BringToFront then
        CensuraG.Desktop:BringToFront()
    elseif CensuraG.Desktop and CensuraG.Desktop.ShowStartMenu then
        CensuraG.Desktop:ShowStartMenu()
    end
end

-- Performance and system information
CensuraG.GetPerformanceMetrics = function()
    local totalInitTime = tick() - initStartTime
    return {
        InitializationTime = totalInitTime,
        SessionId = sessionId,
        Version = CensuraG.Version,
        LoadedComponents = #CensuraG.Components,
        LoadedManagers = #CensuraG.Managers,
        ActiveWindows = CensuraG.Windows and #CensuraG.Windows or 0,
        MemoryUsage = collectgarbage("count"),
        BuildNumber = CensuraG.BuildNumber
    }
end

-- Mark as fully initialized
CensuraG.Initialized = true
CensuraG.Loading = false

-- Hide splash screen with completion effect
if splash then 
    splash:UpdateStatus("CensuraG Ready!", 1.0)
    task.delay(0.8, function()
        splash:Hide()
    end)
end

-- Final performance metrics
local totalInitTime = tick() - initStartTime
local metrics = CensuraG.GetPerformanceMetrics()

CensuraG.Logger:section("CensuraG Modern Desktop Environment Ready")
CensuraG.Logger:info(string.format("🚀 Initialization complete in %.2fms", totalInitTime * 1000))
CensuraG.Logger:info("📋 Session: " .. sessionId)
CensuraG.Logger:info("🎨 Theme: " .. (CensuraG.Config and CensuraG.Config.CurrentTheme or "Default"))
CensuraG.Logger:info(string.format("🧩 Components: %d loaded", metrics.LoadedComponents))
CensuraG.Logger:info(string.format("⚙️ Managers: %d active", metrics.LoadedManagers))
CensuraG.Logger:info(string.format("💾 Memory: %.1fKB", metrics.MemoryUsage))
CensuraG.Logger:info("✨ Modern glassmorphic interface ready")

-- Optional debug remote (commented for production)
-- task.spawn(function()
--     loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Censura-Applications/main/Services/Remote.lua"))()
-- end)

return CensuraG
