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

-- Global State
CensuraG.Windows = CensuraG.Windows or {}
CensuraG.Taskbar = CensuraG.Taskbar or nil

-- Initialize Taskbar
if not CensuraG.Taskbar then
    CensuraG.TaskbarManager:Initialize()
    CensuraG.Logger:info("Taskbar initialized")
end

return CensuraG
