-- CensuraG.lua: Entry point for the CensuraG UI API
-- Loads scripts dynamically and initializes the global API table
local CensuraG = {}
_G.CensuraG = CensuraG

local baseUrl = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/"

-- Load a script from the repository
local function loadScript(path)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(baseUrl .. path))()
    end)
    if not success then
        warn("Failed to load " .. path .. ": " .. result)
        return nil
    end
    return result
end

-- Load dependencies
CensuraG.Utilities = loadScript("Utilities.lua")
CensuraG.UIElement = loadScript("UIElement.lua")
CensuraG.Styling = loadScript("Styling.lua")
CensuraG.Animation = loadScript("Animation.lua")
CensuraG.Draggable = loadScript("Draggable.lua")
CensuraG.Window = loadScript("Elements/Window.lua")
CensuraG.TextButton = loadScript("Elements/TextButton.lua")
CensuraG.Slider = loadScript("Elements/Slider.lua")
CensuraG.Switch = loadScript("Elements/Switch.lua") -- Added

-- Initialize ScreenGui
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
CensuraG.ScreenGui = PlayerGui:FindFirstChild("CensuraGGui") or CensuraG.Utilities.createInstance("ScreenGui", {
    Parent = PlayerGui,
    Name = "CensuraGGui",
    ResetOnSpawn = false
})

-- API extension method
function CensuraG.AddCustomElement(name, class)
    CensuraG[name] = class
end

return CensuraG
