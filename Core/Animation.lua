-- Core/Animation.lua: Simplified and reliable animation system
local Animation = {}
local TweenService = game:GetService("TweenService")

-- Store active tweens
local activeTweens = {}

-- Clean up completed tweens
local function cleanupTweens()
    for i = #activeTweens, 1, -1 do
        if not activeTweens[i].Instance or activeTweens[i].Completed then
            table.remove(activeTweens, i)
        end
    end
end

-- General tween function
function Animation:Tween(element, properties, duration, easingStyle, easingDirection, callback)
    if not element or not element.Parent then return end
    self:CancelTweens(element)
    
    local tweenInfo = TweenInfo.new(duration or 0.2, easingStyle or Enum.EasingStyle.Quad, easingDirection or Enum.EasingDirection.Out)
    local tween = TweenService:Create(element, tweenInfo, properties)
    
    table.insert(activeTweens, {Instance = element, Tween = tween, Completed = false})
    
    tween.Completed:Connect(function()
        if callback then callback() end
        cleanupTweens()
    end)
    
    tween:Play()
end

-- Cancel active tweens for an element
function Animation:CancelTweens(element)
    for i, tweenData in ipairs(activeTweens) do
        if tweenData.Instance == element and not tweenData.Completed then
            tweenData.Tween:Cancel()
            tweenData.Completed = true
        end
    end
end

return Animation
