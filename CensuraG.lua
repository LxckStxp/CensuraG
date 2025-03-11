-- CensuraG/CensuraG.lua
local Oratio = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/Oratio/main/init.lua", true))()
if not Oratio then error("Failed to load Oratio") end

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

-- Load Utilities
local Utilities = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/Utilities.lua"))()
CensuraG.Utilities = Utilities

-- Load Core Modules
CensuraG.Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/Config.lua"))()
CensuraG.Methods = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/Methods.lua"))()
CensuraG.WindowManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/WindowManager.lua"))()
CensuraG.TaskbarManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/TaskbarManager.lua"))()
CensuraG.AnimationManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/ui/AnimationManager.lua"))()

-- Load Components
CensuraG.Components = {}
local componentList = {
    "window", "taskbar", "textlabel", "textbutton", "imagelabel", "slider", "dropdown", "switch"
}

for _, component in ipairs(componentList) do
    local url = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/components/" .. component .. ".lua"
    local loadedComponent = CensuraG.Utilities.LoadModule(url)
    if loadedComponent then
        CensuraG.Components[component] = loadedComponent
        CensuraG.Logger:info("Loaded component: " .. component)
    else
        CensuraG.Logger:error("Failed to load component: " .. component)
    end
end

-- Global State
CensuraG.Windows = CensuraG.Windows or {}
CensuraG.Taskbar = CensuraG.Taskbar or nil

-- Initialize Taskbar
if not CensuraG.Taskbar then
    CensuraG.TaskbarManager:Initialize()
    CensuraG.Logger:info("Taskbar initialized")
end

CensuraG.Logger:info("CensuraG initialization complete")
return CensuraG
