-- CensuraG.lua: Entry point for the CensuraG UI API
-- Loads all scripts dynamically from LxckStxp/CensuraG/src/
-- Date: March 09, 2025

local baseUrl = "https://raw.githubusercontent.com/LxckStxp/CensuraG/main/src/"

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

-- Initialize global table
local CensuraG = {}
_G.CensuraG = CensuraG

-- Load dependencies
CensuraG.Utilities = loadScript("Utilities.lua")
CensuraG.UIElement = loadScript("UIElement.lua")
CensuraG.Styling = loadScript("Styling.lua")
CensuraG.Animation = loadScript("Animation.lua")
CensuraG.Draggable = loadScript("Draggable.lua") -- Added
CensuraG.WindowManager = loadScript("WindowManager.lua") -- Added
CensuraG.Window = loadScript("Elements/Window.lua")
CensuraG.TextButton = loadScript("Elements/TextButton.lua")
CensuraG.Slider = loadScript("Elements/Slider.lua")
CensuraG.Taskbar = loadScript("Taskbar.lua")

-- Setup ScreenGui
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
CensuraG.ScreenGui = PlayerGui:FindFirstChild("CensuraGGui") or CensuraG.Utilities.createInstance("ScreenGui", {
    Parent = PlayerGui,
    Name = "CensuraGGui"
})

-- API Expansion
function CensuraG.AddCustomElement(name, class)
    CensuraG[name] = class
end

-- Initialize Taskbar and WindowManager
if CensuraG.Taskbar then
    CensuraG.Taskbar:Init()
end
if CensuraG.WindowManager then
    CensuraG.WindowManager:Init()
end

return CensuraG
