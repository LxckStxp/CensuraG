-- Animation.lua: Subtle animations for UI elements
local Animation = {}
local TweenService = game:GetService("TweenService")

-- Default tween settings for a smooth, subtle effect
local defaultTweenInfo = TweenInfo.new(
    0.3,                  -- Duration
    Enum.EasingStyle.Quad,-- Easing style (smooth start/end)
    Enum.EasingDirection.Out
)

-- Animate an instance
function Animation:Tween(instance, properties, tweenInfo)
    tweenInfo = tweenInfo or defaultTweenInfo
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Common animations
function Animation:FadeIn(instance)
    instance.Visible = true
    self:Tween(instance, {BackgroundTransparency = 0.1, TextTransparency = 0})
end

function Animation:FadeOut(instance)
    local tween = self:Tween(instance, {BackgroundTransparency = 1, TextTransparency = 1})
    tween.Completed:Connect(function()
        instance.Visible = false
    end)
end

function Animation:HoverEffect(instance)
    instance.MouseEnter:Connect(function()
        self:Tween(instance, {BackgroundColor3 = _G.CensuraG.Styling.Colors.Highlight})
    end)
    instance.MouseLeave:Connect(function()
        self:Tween(instance, {BackgroundColor3 = _G.CensuraG.Styling.Colors.Accent})
    end)
end

return Animation
