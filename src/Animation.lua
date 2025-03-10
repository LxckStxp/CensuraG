-- Animation.lua: Animation utilities for smooth transitions
local Animation = {}
local TweenService = game:GetService("TweenService")
local logger = _G.CensuraG.Logger

function Animation:SlideY(element, targetY, duration, easingStyle, easingDirection, callback)
    local style = easingStyle or Enum.EasingStyle.Quad
    local direction = easingDirection or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration or 0.3, style, direction)
    local targetPosition = UDim2.new(element.Position.X.Scale, element.Position.X.Offset, element.Position.Y.Scale, targetY)
    local tween = TweenService:Create(element, tweenInfo, {Position = targetPosition})
    logger:debug("Sliding element %s to Y: %d", tostring(element), targetY)
    if callback then tween.Completed:Connect(callback) end
    tween:Play()
    return tween
end

function Animation:Tween(element, properties, duration, easingStyle, easingDirection, callback)
    local style = easingStyle or Enum.EasingStyle.Quad
    local direction = easingDirection or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration or 0.2, style, direction)
    local tween = TweenService:Create(element, tweenInfo, properties)
    logger:debug("Tweening element %s with properties: %s", tostring(element), tostring(properties))
    if callback then tween.Completed:Connect(callback) end
    tween:Play()
    return tween
end

function Animation:HoverEffect(element)
    element.MouseEnter:Connect(function()
        Animation:Tween(element, {BackgroundTransparency = _G.CensuraG.Styling.Transparency.ElementBackground - 0.1}, 0.1)
        logger:debug("Hover effect on: %s", tostring(element))
    end)
    element.MouseLeave:Connect(function()
        Animation:Tween(element, {BackgroundTransparency = _G.CensuraG.Styling.Transparency.ElementBackground}, 0.1)
        logger:debug("Hover effect off: %s", tostring(element))
    end)
end

return Animation
