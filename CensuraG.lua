-- CensuraG.lua
-- Main entry point for the CensuraG UI API

local CensuraG = rawget(_G, "CensuraG") or {}
_G.CensuraG = CensuraG

-- Centralized Configuration
CensuraG.Config = CensuraG.Config or {
    Theme = {
        PrimaryColor = Color3.fromRGB(30, 30, 30),    -- Dark gray (monochromatic)
        SecondaryColor = Color3.fromRGB(50, 50, 50),  -- Lighter gray
        AccentColor = Color3.fromRGB(0, 105, 92),     -- Muted teal
        Font = Enum.Font.Code,                        -- Miltech-inspired font
        TextColor = Color3.fromRGB(200, 200, 200),    -- Light gray text
    },
    WindowSize = Vector2.new(300, 200),               -- Default window size
    TaskbarHeight = 40                                -- Taskbar height
}

-- Global State
CensuraG.Windows = CensuraG.Windows or {}             -- Active windows
CensuraG.Taskbar = CensuraG.Taskbar or nil            -- Taskbar instance

-- Utility Functions
local function loadModule(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not success then warn("Failed to load module: " .. result) end
    return success and result or nil
end

-- Load Core Modules
CensuraG.WindowManager = CensuraG.WindowManager or loadModule("https://raw.githubusercontent.com/LxckStxp/CensuraG/main/WindowManager.lua")
CensuraG.TaskbarManager = CensuraG.TaskbarManager or loadModule("https://raw.githubusercontent.com/LxckStxp/CensuraG/main/TaskbarManager.lua")

-- API Functions
function CensuraG:CreateWindow(title)
    if not self.WindowManager then return warn("WindowManager not loaded") end
    local window = self.WindowManager.new(title)
    table.insert(self.Windows, window)
    self.TaskbarManager:UpdateTaskbar()
    return window
end

-- Initialize Taskbar
if not CensuraG.Taskbar then
    CensuraG.TaskbarManager:Initialize()
end

return CensuraG
