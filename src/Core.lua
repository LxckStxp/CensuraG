-- Core.lua: Entry point and global initialization
local CensuraG = {}
_G.CensuraG = CensuraG

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Load dependencies (these will be concatenated in the final build)
local Utilities = require(script.Parent.Utilities)
local UIElement = require(script.Parent.UIElement)
local Window = require(script.Parent.Elements.Window)
local TextButton = require(script.Parent.Elements.TextButton)
local Slider = require(script.Parent.Elements.Slider)
local Taskbar = require(script.Parent.Taskbar)

-- Expose classes and modules
CensuraG.Utilities = Utilities
CensuraG.UIElement = UIElement
CensuraG.Window = Window
CensuraG.TextButton = TextButton
CensuraG.Slider = Slider
CensuraG.Taskbar = Taskbar

-- Initialize the ScreenGui
CensuraG.ScreenGui = PlayerGui:FindFirstChild("CensuraGGui") or Utilities.createInstance("ScreenGui", {
    Parent = PlayerGui,
    Name = "CensuraGGui"
})

-- API Expansion
function CensuraG.AddCustomElement(name, class)
    CensuraG[name] = class
end

-- Initialize Taskbar
CensuraG.Taskbar:Init()

return CensuraG
