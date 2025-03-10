-- Animation.lua: Simple animation utilities
local Animation = {}
local TweenService = game:GetService("TweenService")

function Animation:Tween(element, properties, duration, callback)
    local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(element, tweenInfo, properties)
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
    end)
    element.MouseLeave:Connect(function()
        element.BorderSizePixel = 0
    end)
end

return Animation
