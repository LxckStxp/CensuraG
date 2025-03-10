-- Core/Animation.lua
-- Enhanced animation system using TweenService with AnimationSpeed scaling and full compatibility with CensuraG framework

local TweenService = game:GetService("TweenService") or { Create = function() return { Play = function() end, Completed = Instance.new("BindableEvent") } end }
local Animation = {}
local activeTweens = {}
local hoverConnections = {}

-- Private helper functions
local function cleanupTweens()
    for i = #activeTweens, 1, -1 do
        if activeTweens[i].Completed then
            table.remove(activeTweens, i)
        end
    end
end

local function getScaledDuration(duration, defaultValue)
    local speed = _G.CensuraG.Config and _G.CensuraG.Config.AnimationSpeed or 1.0
    return (duration or defaultValue) / math.max(0.1, speed) -- Prevent division by zero or negative speed
end

local function validateElement(element)
    return element and element.Parent ~= nil
end

local function createAndPlayTween(element, info, properties, callback)
    if not validateElement(element) then
        return nil
    end
    
    local tween = TweenService:Create(element, info, properties)
    local tweenData = { Instance = element, Tween = tween, Completed = false }
    
    table.insert(activeTweens, tweenData)
    
    tween.Completed:Connect(function()
        tweenData.Completed = true
        if callback then 
            pcall(callback) -- Wrap callback in pcall to prevent errors from breaking cleanup
        end
        task.delay(1, cleanupTweens)
    end)
    
    tween:Play()
    return tween
end

-- Public API
function Animation:Tween(element, properties, duration, easingStyle, easingDirection, callback)
    if not validateElement(element) then
        return nil
    end
    
    local scaledDuration = getScaledDuration(duration, 0.3)
    local info = TweenInfo.new(
        scaledDuration, 
        easingStyle or Enum.EasingStyle.Quad, 
        easingDirection or Enum.EasingDirection.Out
    )
    
    return createAndPlayTween(element, info, properties, callback)
end

function Animation:Elastic(element, properties, duration, callback)
    if not validateElement(element) then
        return nil
    end
    
    local scaledDuration = getScaledDuration(duration, 0.5)
    local info = TweenInfo.new(
        scaledDuration, 
        Enum.EasingStyle.Elastic, 
        Enum.EasingDirection.Out, 
        0, false, 0
    )
    
    return createAndPlayTween(element, info, properties, callback)
end

function Animation:Bounce(element, scale, duration, callback)
    if not validateElement(element) then
        return nil
    end
    
    local originalSize = element.Size
    local scaledSize = UDim2.new(
        originalSize.X.Scale * scale, 
        originalSize.X.Offset * scale,
        originalSize.Y.Scale * scale, 
        originalSize.Y.Offset * scale
    )
    
    self:Tween(element, { Size = scaledSize }, duration * 0.5, Enum.EasingStyle.Bounce, nil, function()
        self:Tween(element, { Size = originalSize }, duration * 0.5, nil, nil, callback)
    end)
end

function Animation:SlideY(element, targetY, duration, easingStyle, easingDirection, callback)
    if not validateElement(element) then
        return nil
    end
    
    local scaledDuration = getScaledDuration(duration, 0.3)
    local currentPos = element.Position
    local info = TweenInfo.new(
        scaledDuration, 
        easingStyle or Enum.EasingStyle.Quad, 
        easingDirection or Enum.EasingDirection.Out
    )
    
    local targetPosition = UDim2.new(
        currentPos.X.Scale, 
        currentPos.X.Offset, 
        0, 
        targetY
    )
    
    return createAndPlayTween(element, info, { Position = targetPosition }, callback)
end

function Animation:SlideX(element, targetX, duration, easingStyle, easingDirection, callback)
    if not validateElement(element) then
        return nil
    end
    
    local scaledDuration = getScaledDuration(duration, 0.3)
    local currentPos = element.Position
    local info = TweenInfo.new(
        scaledDuration, 
        easingStyle or Enum.EasingStyle.Quad, 
        easingDirection or Enum.EasingDirection.Out
    )
    
    local targetPosition = UDim2.new(
        0, 
        targetX, 
        currentPos.Y.Scale, 
        currentPos.Y.Offset
    )
    
    return createAndPlayTween(element, info, { Position = targetPosition }, callback)
end

function Animation:Fade(element, transparency, duration, callback)
    if not validateElement(element) then
        return nil
    end
    
    local property = element:IsA("TextLabel") or element:IsA("TextButton") or element:IsA("TextBox") 
        and "TextTransparency" 
        or element:IsA("ImageLabel") or element:IsA("ImageButton") 
            and "ImageTransparency" 
            or "BackgroundTransparency"
    
    local properties = {}
    properties[property] = transparency
    
    return self:Tween(element, properties, duration, nil, nil, callback)
end

function Animation:CancelTweens(element)
    if not element then return end
    
    for i = #activeTweens, 1, -1 do
        local tweenData = activeTweens[i]
        if tweenData.Instance == element and not tweenData.Completed then
            tweenData.Tween:Cancel()
            tweenData.Completed = true
            table.remove(activeTweens, i)
        end
    end
end

function Animation:HoverEffect(element, hoverProps, leaveProps)
    if not validateElement(element) then
        return nil
    end
    
    local id = tostring(element) .. "_hover"
    
    -- Clean up existing connections if any
    self:CleanupHoverEffects(element)
    
    hoverConnections[id] = {}
    local originalSize = element.Size
    local originalTransparency = element.BackgroundTransparency
    
    -- Default hover properties if none provided
    hoverProps = hoverProps or { 
        Size = UDim2.new(
            originalSize.X.Scale * 1.05, 
            originalSize.X.Offset, 
            originalSize.Y.Scale * 1.05, 
            originalSize.Y.Offset
        ),
        BackgroundTransparency = math.max(0, originalTransparency - 0.1)
    }
    
    -- Default leave properties if none provided
    leaveProps = leaveProps or { 
        Size = originalSize, 
        BackgroundTransparency = originalTransparency 
    }
    
    local function onHover()
        self:Elastic(element, hoverProps, 0.3)
    end
    
    local function onLeave()
        self:Elastic(element, leaveProps, 0.3)
    end
    
    table.insert(hoverConnections[id], element.MouseEnter:Connect(onHover))
    table.insert(hoverConnections[id], element.MouseLeave:Connect(onLeave))
    
    return id
end

function Animation:CleanupHoverEffects(element)
    if not element then return end
    
    local id = tostring(element) .. "_hover"
    if hoverConnections[id] then
        for _, conn in ipairs(hoverConnections[id]) do
            conn:Disconnect()
        end
        hoverConnections[id] = nil
    end
end

function Animation:PulseEffect(element, intensity, duration, times, callback)
    if not validateElement(element) then
        return
    end
    
    times = times or 1
    intensity = intensity or 1.1
    duration = duration or 0.5
    local originalSize = element.Size
    
    local function doPulse(remaining)
        if remaining <= 0 then
            if callback then pcall(callback) end
            return
        end
        
        local pulseSize = UDim2.new(
            originalSize.X.Scale * intensity,
            originalSize.X.Offset,
            originalSize.Y.Scale * intensity,
            originalSize.Y.Offset
        )
        
        self:Tween(element, { Size = pulseSize }, duration/2, nil, nil, function()
            self:Tween(element, { Size = originalSize }, duration/2, nil, nil, function()
                doPulse(remaining - 1)
            end)
        end)
    end
    
    doPulse(times)
end

function Animation:SequentialFade(elements, transparency, delay, duration, callback)
    if not elements or #elements == 0 then
        if callback then pcall(callback) end
        return
    end
    
    local function fadeNext(index)
        if index > #elements then
            if callback then pcall(callback) end
            return
        end
        
        local element = elements[index]
        if validateElement(element) then
            self:Fade(element, transparency, duration, function()
                task.delay(delay, function()
                    fadeNext(index + 1)
                end)
            end)
        else
            fadeNext(index + 1)
        end
    end
    
    fadeNext(1)
end

function Animation:ShakeEffect(element, intensity, times, callback)
    if not validateElement(element) then
        return
    end
    
    intensity = intensity or 5
    times = times or 5
    local originalPosition = element.Position
    
    local function doShake(remaining, direction)
        if remaining <= 0 then
            self:Tween(element, { Position = originalPosition }, 0.1, nil, nil, callback)
            return
        end
        
        local offset = direction * intensity
        local newPosition = UDim2.new(
            originalPosition.X.Scale,
            originalPosition.X.Offset + offset,
            originalPosition.Y.Scale,
            originalPosition.Y.Offset
        )
        
        self:Tween(element, { Position = newPosition }, 0.05, nil, nil, function()
            doShake(remaining - 1, direction * -1)
        end)
    end
    
    doShake(times, 1)
end

return Animation
