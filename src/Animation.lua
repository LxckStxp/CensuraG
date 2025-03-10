-- Animation.lua: Simple animation utilities
local Animation = {}
local TweenService = game:GetService("TweenService")
local logger = _G.CensuraG.Logger

function Animation:Tween(element, properties, duration, callback)
    local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(element, tweenInfo, properties)
    logger:debug("Started tween for element: %s, Properties: %s", tostring(element), tostring(properties))
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
