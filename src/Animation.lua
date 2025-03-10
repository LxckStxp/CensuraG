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

function Animation:HoverEffect(button)
    local originalColor = button.BackgroundColor3
    button.MouseEnter:Connect(function()
        self:Tween(button, {BackgroundColor3 = Styling.Colors.Accent})
    end)
    button.MouseLeave:Connect(function()
        self:Tween(button, {BackgroundColor3 = originalColor})
    end)
end

return Animation
