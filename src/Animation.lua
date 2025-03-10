-- Animation.lua: Simple animation utilities for Y-axis sliding
local Animation = {}
local TweenService = game:GetService("TweenService")
local logger = _G.CensuraG.Logger

function Animation:SlideY(element, targetY, duration, callback)
    local tweenInfo = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local currentPosition = element.Position
    local targetPosition = UDim2.new(currentPosition.X.Scale, currentPosition.X.Offset, 0, targetY)
    local tween = TweenService:Create(element, tweenInfo, {Position = targetPosition})
    logger:debug("Started Y-axis slide for element: %s, Target Y: %d", tostring(element), targetY)
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
