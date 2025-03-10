-- Animation.lua: Animation utilities for Y-axis sliding and generic tweens
local Animation = {}
local TweenService = game:GetService("TweenService")
local logger = _G.CensuraG.Logger

function Animation:SlideY(element, targetY, duration, easingStyle, easingDirection, callback)
    local style = easingStyle or Enum.EasingStyle.Linear
    local direction = easingDirection or Enum.EasingDirection.InOut
    local tweenInfo = TweenInfo.new(duration or 0.3, style, direction)
    local currentPosition = element.Position
    local targetPosition = UDim2.new(currentPosition.X.Scale, currentPosition.X.Offset, 0, targetY)
    local tween = TweenService:Create(element, tweenInfo, {Position = targetPosition})
    logger:debug("Started Y-axis slide for element: %s, Target Y: %d, Easing: %s, Direction: %s", tostring(element), targetY, tostring(style), tostring(direction))
    if callback then
        tween.Completed:Connect(callback)
    end
    tween:Play()
    return tween
end

function Animation:Tween(element, properties, duration, callback)
    local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(element, tweenInfo, properties)
    logger:debug("Started tween for element: %s, Properties: %s, Duration: %.2f", tostring(element), tostring(properties), duration or 0.2)
    if callback then
        tween.Completed:Connect(callback)
    end
    tween:Play()
    return tween
end

function Animation:HoverEffect(element)
    element.MouseEnter:Connect(function()
        element.BorderSizePixel = 1
        element.BorderColor3 = _G.CensuraG.Styling.Colors.Accent
        logger:debug("Hover effect applied to element: %s", tostring(element))
    end)
    element.MouseLeave:Connect(function()
        element.BorderSizePixel = 0
        logger:debug("Hover effect removed from element: %s", tostring(element))
    end)
end

return Animation
