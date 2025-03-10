-- Core/Animation.lua: Enhanced animation system
local Animation = {}
local TweenService = game:GetService("TweenService")
local logger = _G.CensuraG.Logger

-- Track active tweens for cleanup
local activeTweens = {}

-- Clean up completed tweens periodically
local function cleanupTweens()
    for i = #activeTweens, 1, -1 do
        if not activeTweens[i].Instance or activeTweens[i].Completed then
            table.remove(activeTweens, i)
        end
    end
end

-- Slide an element vertically
function Animation:SlideY(element, targetY, duration, easingStyle, easingDirection, callback)
    if not element or not element.Parent then
        logger:warn("Cannot animate non-existent element")
        return nil
    end
    
    -- Cancel any active tweens on this element
    self:CancelTweens(element)
    
    local style = easingStyle or Enum.EasingStyle.Quad
    local direction = easingDirection or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration or 0.3, style, direction)
    local targetPosition = UDim2.new(
        element.Position.X.Scale, 
        element.Position.X.Offset, 
        element.Position.Y.Scale, 
        targetY
    )
    
    local tween = TweenService:Create(element, tweenInfo, {Position = targetPosition})
    
    local tweenData = {
        Instance = element,
        Tween = tween,
        Completed = false
    }
    
    table.insert(activeTweens, tweenData)
    
    tween.Completed:Connect(function()
        tweenData.Completed = true
        if callback then callback() end
        task.delay(1, cleanupTweens) -- Cleanup after a delay
    end)
    
    tween:Play()
    logger:debug("Sliding element %s to Y: %d", tostring(element), targetY)
    return tween
end

-- General purpose tweening
function Animation:Tween(element, properties, duration, easingStyle, easingDirection, callback)
    if not element or not element.Parent then
        logger:warn("Cannot animate non-existent element")
        return nil
    end
    
    -- Cancel any active tweens on this element
    self:CancelTweens(element)
    
    local style = easingStyle or Enum.EasingStyle.Quad
    local direction = easingDirection or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(duration or 0.2, style, direction)
    
    local tween = TweenService:Create(element, tweenInfo, properties)
    
    local tweenData = {
        Instance = element,
        Tween = tween,
        Completed = false
    }
    
    table.insert(activeTweens, tweenData)
    
    tween.Completed:Connect(function()
        tweenData.Completed = true
        if callback then callback() end
        task.delay(1, cleanupTweens) -- Cleanup after a delay
    end)
    
    tween:Play()
    logger:debug("Tweening element %s with properties: %s", tostring(element), tostring(properties))
    return tween
end

-- Cancel active tweens for an element
function Animation:CancelTweens(element)
    for i, tweenData in ipairs(activeTweens) do
        if tweenData.Instance == element and not tweenData.Completed then
            tweenData.Tween:Cancel()
            tweenData.Completed = true
            logger:debug("Cancelled tween for element %s", tostring(element))
        end
    end
end

-- Add hover effect to an element
function Animation:HoverEffect(element, hoverProperties, leaveProperties)
    if not element then return end
    
    hoverProperties = hoverProperties or {
        BackgroundTransparency = _G.CensuraG.Styling.Transparency.ElementBackground - 0.1
    }
    
    leaveProperties = leaveProperties or {
        BackgroundTransparency = _G.CensuraG.Styling.Transparency.ElementBackground
    }
    
    local connections = {}
    
    table.insert(connections, element.MouseEnter:Connect(function()
        Animation:Tween(element, hoverProperties, 0.1)
        logger:debug("Hover effect on: %s", tostring(element))
    end))
    
    table.insert(connections, element.MouseLeave:Connect(function()
        Animation:Tween(element, leaveProperties, 0.1)
        logger:debug("Hover effect off: %s", tostring(element))
    end))
    
    -- Store connections for cleanup
    element:SetAttribute("HoverEffectConnections", connections)
    
    return connections
end

-- Fade in effect
function Animation:FadeIn(element, duration, callback)
    if not element then return nil end
    
    local properties = {
        BackgroundTransparency = element.BackgroundTransparency - 0.5
    }
    
    if element:IsA("TextLabel") or element:IsA("TextButton") then
        properties.TextTransparency = 0
    end
    
    if element:IsA("ImageLabel") or element:IsA("ImageButton") then
        properties.ImageTransparency = 0
    end
    
    return self:Tween(element, properties, duration or 0.3, nil, nil, callback)
end

-- Fade out effect
function Animation:FadeOut(element, duration, callback)
    if not element then return nil end
    
    local properties = {
        BackgroundTransparency = element.BackgroundTransparency + 0.5
    }
    
    if element:IsA("TextLabel") or element:IsA("TextButton") then
        properties.TextTransparency = 1
    end
    
    if element:IsA("ImageLabel") or element:IsA("ImageButton") then
        properties.ImageTransparency = 1
    end
    
    return self:Tween(element, properties, duration or 0.3, nil, nil, callback)
end

-- Bounce effect
function Animation:Bounce(element, intensity, duration, callback)
    if not element then return nil end
    
    intensity = intensity or 1.1
    duration = duration or 0.2
    
    local originalSize = element.Size
    local targetSize = UDim2.new(
        originalSize.X.Scale * intensity,
        originalSize.X.Offset * intensity,
        originalSize.Y.Scale * intensity,
        originalSize.Y.Offset * intensity
    )
    
    self:Tween(element, {Size = targetSize}, duration / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, function()
        self:Tween(element, {Size = originalSize}, duration / 2, Enum.EasingStyle.Quad, Enum.EasingDirection
