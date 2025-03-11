-- CensuraG/CensuraG.lua
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

-- Initialize the library
local Oratio, oratioError = safeLoadstring("https://raw.githubusercontent.com/LxckStxp/Oratio/main/init.lua", "Failed to load Oratio")
if not Oratio then error("Failed to load Oratio: " .. (oratioError or "Unknown error")) end

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
local coreModules = {
    Config = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/Config.lua",
    Methods = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/Methods.lua",
    AnimationManager = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/AnimationManager.lua"
}

local allCoreModulesLoaded = true
for name, url in pairs(coreModules) do
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

-- Load Components with better error handling
CensuraG.Components = {}
local componentList = {
    "window", "taskbar", "textlabel", "textbutton", "imagelabel", "slider", "dropdown", "switch", "grid"
}

local allComponentsLoaded = true
for _, component in ipairs(componentList) do
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
    local managerModules = {
        WindowManager = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/WindowManager.lua",
        TaskbarManager = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/TaskbarManager.lua"
    }
    
    local allManagersLoaded = true
    for name, url in pairs(managerModules) do
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
    
    -- Global State
    CensuraG.Windows = CensuraG.Windows or {}
    CensuraG.Taskbar = CensuraG.Taskbar or nil
    
    -- Initialize Taskbar only if TaskbarManager loaded
    if CensuraG.TaskbarManager and not CensuraG.Taskbar then
        pcall(function()
            CensuraG.Taskbar = { Instance = CensuraG.TaskbarManager }
            CensuraG.Taskbar.Instance:Initialize()
            CensuraG.Logger:info("Taskbar initialized")
        end)
    end
else
    CensuraG.Logger:error("Not initializing managers due to missing components")
end

CensuraG.Logger:info("CensuraG initialization complete")
return CensuraG
