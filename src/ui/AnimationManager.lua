-- CensuraG/src/ui/AnimationManager.lua
local AnimationManager = {}
AnimationManager.__index = AnimationManager

local TweenService = game:GetService("TweenService")

function AnimationManager:Tween(object, properties, duration, easingStyle, easingDirection)
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    duration = duration or 0.3
    
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    
    _G.CensuraG.Logger:info("Tween started on " .. object.Name)
    tween.Completed:Connect(function()
        _G.CensuraG.Logger:info("Tween completed on " .. object.Name)
    end)
end

return AnimationManager
