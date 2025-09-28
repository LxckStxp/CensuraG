-- CensuraG/src/ui/AnimationManager.lua (Modern High-Performance Animation System v2.0)
-- Sophisticated micro-animations with performance optimization and advanced effects

local AnimationManager = {}
AnimationManager.__index = AnimationManager

-- Core services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Performance optimization
local activeAnimations = {}
local animationQueue = {}
local maxConcurrentAnimations = 12
local frameTime = 0
local lastFrameStart = 0

-- Animation presets for consistency and performance
local ANIMATION_PRESETS = {
    -- Micro-interactions (subtle feedback)
    Micro = {
        Duration = 0.08,
        Easing = Enum.EasingStyle.Quad,
        Direction = Enum.EasingDirection.Out
    },
    
    -- Standard interactions
    Standard = {
        Duration = 0.15,
        Easing = Enum.EasingStyle.Quart,
        Direction = Enum.EasingDirection.Out
    },
    
    -- Entrance animations  
    Entrance = {
        Duration = 0.25,
        Easing = Enum.EasingStyle.Back,
        Direction = Enum.EasingDirection.Out
    },
    
    -- Exit animations
    Exit = {
        Duration = 0.18,
        Easing = Enum.EasingStyle.Quad,
        Direction = Enum.EasingDirection.In
    },
    
    -- State changes
    StateChange = {
        Duration = 0.3,
        Easing = Enum.EasingStyle.Cubic,
        Direction = Enum.EasingDirection.InOut
    },
    
    -- Elastic feedback
    Elastic = {
        Duration = 0.4,
        Easing = Enum.EasingStyle.Elastic,
        Direction = Enum.EasingDirection.Out
    },
    
    -- Bounce effect
    Bounce = {
        Duration = 0.35,
        Easing = Enum.EasingStyle.Bounce,
        Direction = Enum.EasingDirection.Out
    }
}

function AnimationManager:Initialize()
    -- Performance monitoring
    RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        frameTime = (currentTime - lastFrameStart) * 1000
        lastFrameStart = currentTime
        
        -- Clean up completed animations
        self:CleanupAnimations()
        
        -- Process queued animations if we have capacity
        self:ProcessAnimationQueue()
    end)
    
    -- Reduce animations on low-end devices
    if UserInputService.TouchEnabled then
        maxConcurrentAnimations = 8
    end
    
    _G.CensuraG.Logger:debug("AnimationManager v2.0 initialized with performance monitoring")
end

-- Core animation system with performance optimization
function AnimationManager:Tween(object, properties, duration, easingStyle, easingDirection, preset)
    -- Validation
    if not self:ValidateAnimation(object, properties) then
        return nil
    end
    
    -- Use preset if specified
    if preset and ANIMATION_PRESETS[preset] then
        local presetData = ANIMATION_PRESETS[preset]
        duration = duration or presetData.Duration
        easingStyle = easingStyle or presetData.Easing
        easingDirection = easingDirection or presetData.Direction
    else
        duration = duration or ANIMATION_PRESETS.Standard.Duration
        easingStyle = easingStyle or ANIMATION_PRESETS.Standard.Easing
        easingDirection = easingDirection or ANIMATION_PRESETS.Standard.Direction
    end
    
    -- Performance check
    if #activeAnimations >= maxConcurrentAnimations then
        table.insert(animationQueue, {
            object = object,
            properties = properties,
            duration = duration,
            easingStyle = easingStyle,
            easingDirection = easingDirection
        })
        return nil
    end
    
    -- Optimize properties
    local optimizedProperties = self:OptimizeProperties(object, properties)
    
    -- Create and execute animation
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(object, tweenInfo, optimizedProperties)
    
    -- Track animation for performance
    local animationId = tostring(tween)
    activeAnimations[animationId] = {
        tween = tween,
        object = object,
        startTime = tick()
    }
    
    -- Cleanup on completion
    tween.Completed:Connect(function()
        activeAnimations[animationId] = nil
    end)
    
    tween:Play()
    return tween
end

-- Validation system
function AnimationManager:ValidateAnimation(object, properties)
    if not object or typeof(object) ~= "Instance" then
        _G.CensuraG.Logger:warn("Invalid animation target: " .. tostring(object))
        return false
    end
    
    if type(properties) ~= "table" or next(properties) == nil then
        _G.CensuraG.Logger:warn("Invalid animation properties")
        return false
    end
    
    return true
end

-- Property optimization to prevent unnecessary calculations
function AnimationManager:OptimizeProperties(object, properties)
    local optimized = {}
    
    for prop, value in pairs(properties) do
        -- Only animate if value is different from current
        local success, currentValue = pcall(function() return object[prop] end)
        
        if success and currentValue ~= value then
            optimized[prop] = value
        elseif not success then
            _G.CensuraG.Logger:warn("Property '" .. prop .. "' not found on " .. (object.Name or "object"))
        end
    end
    
    return optimized
end

-- Performance management
function AnimationManager:CleanupAnimations()
    local currentTime = tick()
    
    for id, animData in pairs(activeAnimations) do
        if currentTime - animData.startTime > 5 then -- Cleanup stale animations
            activeAnimations[id] = nil
        end
    end
end

function AnimationManager:ProcessAnimationQueue()
    if #animationQueue > 0 and #activeAnimations < maxConcurrentAnimations then
        local nextAnimation = table.remove(animationQueue, 1)
        if nextAnimation then
            self:Tween(
                nextAnimation.object,
                nextAnimation.properties,
                nextAnimation.duration,
                nextAnimation.easingStyle,
                nextAnimation.easingDirection
            )
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SOPHISTICATED MICRO-ANIMATIONS & INTERACTION EFFECTS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Modern button interaction system
function AnimationManager:ButtonPress(element, options)
    options = options or {}
    local scaleReduction = options.scaleReduction or 0.05
    local transparencyChange = options.transparencyChange or 0.15
    
    -- Micro scale and transparency animation
    self:Tween(element, {
        Size = element.Size - UDim2.new(0, scaleReduction * element.AbsoluteSize.X, 0, scaleReduction * element.AbsoluteSize.Y),
        BackgroundTransparency = math.clamp(element.BackgroundTransparency - transparencyChange, 0, 1)
    }, nil, nil, nil, "Micro")
    
    -- Enhanced stroke feedback
    if options.stroke then
        self:Tween(options.stroke, {
            Transparency = math.clamp(options.stroke.Transparency - 0.3, 0, 1),
            Thickness = options.stroke.Thickness + 1
        }, nil, nil, nil, "Micro")
    end
end

function AnimationManager:ButtonRelease(element, originalSize, options)
    options = options or {}
    
    -- Elastic return animation
    self:Tween(element, {
        Size = originalSize,
        BackgroundTransparency = element.BackgroundTransparency + (options.transparencyChange or 0.15)
    }, nil, nil, nil, "Elastic")
    
    if options.stroke then
        self:Tween(options.stroke, {
            Transparency = options.stroke.Transparency + 0.3,
            Thickness = options.stroke.Thickness - 1
        }, nil, nil, nil, "Standard")
    end
end

-- Advanced hover system with glassmorphic effects
function AnimationManager:HoverEnter(element, options)
    options = options or {}
    
    -- Primary element animation
    local hoverProps = {
        BackgroundTransparency = math.clamp(element.BackgroundTransparency - 0.08, 0, 1)
    }
    
    -- Scale effect for interactive elements
    if options.enableScale then
        hoverProps.Size = element.Size + UDim2.new(0, 2, 0, 1)
    end
    
    self:Tween(element, hoverProps, nil, nil, nil, "Standard")
    
    -- Enhanced border glow
    if options.stroke then
        self:Tween(options.stroke, {
            Transparency = math.clamp(options.stroke.Transparency - 0.2, 0, 1),
            Color = options.accentColor or Color3.fromRGB(0, 122, 255)
        }, nil, nil, nil, "Standard")
    end
    
    -- Text color enhancement
    if options.textLabel then
        self:Tween(options.textLabel, {
            TextColor3 = options.accentColor or Color3.fromRGB(0, 122, 255)
        }, nil, nil, nil, "Standard")
    end
end

function AnimationManager:HoverExit(element, originalSize, options)
    options = options or {}
    
    -- Return to original state
    local exitProps = {
        BackgroundTransparency = element.BackgroundTransparency + 0.08
    }
    
    if options.enableScale and originalSize then
        exitProps.Size = originalSize
    end
    
    self:Tween(element, exitProps, nil, nil, nil, "Standard")
    
    -- Restore border
    if options.stroke and options.originalStroke then
        self:Tween(options.stroke, {
            Transparency = options.originalStroke.Transparency,
            Color = options.originalStroke.Color
        }, nil, nil, nil, "Standard")
    end
    
    -- Restore text color
    if options.textLabel and options.originalTextColor then
        self:Tween(options.textLabel, {
            TextColor3 = options.originalTextColor
        }, nil, nil, nil, "Standard")
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- ADVANCED ANIMATION EFFECTS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Window entrance with sophisticated staging
function AnimationManager:WindowEntrance(windowFrame, titleBar, content)
    -- Stage 1: Container scale from center
    windowFrame.Size = UDim2.new(0, 0, 0, 0)
    windowFrame.BackgroundTransparency = 1
    
    self:Tween(windowFrame, {
        Size = windowFrame.Size, -- Will be set by WindowManager
        BackgroundTransparency = 0.12 -- Glassmorphic transparency
    }, nil, nil, nil, "Entrance")
    
    -- Stage 2: Title bar slide down (delayed)
    if titleBar then
        titleBar.Position = titleBar.Position - UDim2.new(0, 0, 1, 0)
        task.delay(0.1, function()
            self:Tween(titleBar, {
                Position = titleBar.Position + UDim2.new(0, 0, 1, 0)
            }, nil, nil, nil, "Standard")
        end)
    end
    
    -- Stage 3: Content fade in (more delayed)
    if content then
        content.BackgroundTransparency = 1
        task.delay(0.15, function()
            self:Tween(content, {
                BackgroundTransparency = 0
            }, nil, nil, nil, "Standard")
        end)
    end
end

-- Smooth window exit
function AnimationManager:WindowExit(windowFrame, callback)
    -- Reverse entrance animation
    self:Tween(windowFrame, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Rotation = 2 -- Subtle rotation effect
    }, nil, nil, nil, "Exit")
    
    -- Execute callback after animation
    if callback then
        task.delay(0.2, callback)
    end
end

-- Ripple effect for touch interactions
function AnimationManager:CreateRipple(parent, clickPosition, color)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.Size = UDim2.new(0, 0, 0, 0)
    ripple.Position = UDim2.new(0, clickPosition.X, 0, clickPosition.Y)
    ripple.BackgroundColor3 = color or Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.7
    ripple.BorderSizePixel = 0
    ripple.ZIndex = parent.ZIndex + 1
    ripple.Parent = parent
    
    -- Circular shape
    local corner = Instance.new("UICorner", ripple)
    corner.CornerRadius = UDim.new(1, 0)
    
    -- Animate expansion
    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
    self:Tween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        Position = UDim2.new(0, clickPosition.X - maxSize/2, 0, clickPosition.Y - maxSize/2),
        BackgroundTransparency = 1
    }, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    
    -- Cleanup
    task.delay(0.5, function()
        if ripple.Parent then
            ripple:Destroy()
        end
    end)
end

-- Pulsing attention effect
function AnimationManager:PulseAttention(element, intensity, color)
    intensity = intensity or 1.2
    color = color or Color3.fromRGB(255, 149, 0) -- Warning orange
    
    local originalSize = element.Size
    local originalColor = element.BackgroundColor3
    
    -- Create pulsing loop
    local function pulse()
        self:Tween(element, {
            Size = originalSize * intensity,
            BackgroundColor3 = color
        }, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        
        task.delay(0.5, function()
            self:Tween(element, {
                Size = originalSize,
                BackgroundColor3 = originalColor
            }, 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        end)
    end
    
    return pulse -- Return function to allow manual control
end

-- Shake effect for errors or notifications
function AnimationManager:Shake(element, intensity, duration)
    intensity = intensity or 5
    duration = duration or 0.3
    
    local originalPosition = element.Position
    local shakeCount = 8
    local shakeInterval = duration / shakeCount
    
    for i = 1, shakeCount do
        local offset = (i % 2 == 0) and intensity or -intensity
        task.delay(i * shakeInterval, function()
            element.Position = originalPosition + UDim2.new(0, offset, 0, 0)
        end)
    end
    
    -- Return to original position
    task.delay(duration, function()
        self:Tween(element, {Position = originalPosition}, 0.1)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- PERFORMANCE & UTILITY METHODS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Get current performance metrics
function AnimationManager:GetPerformanceMetrics()
    return {
        ActiveAnimations = #activeAnimations,
        QueuedAnimations = #animationQueue,
        AverageFrameTime = frameTime,
        MaxConcurrent = maxConcurrentAnimations
    }
end

-- Batch animation system for efficiency
function AnimationManager:BatchAnimate(animationList)
    for _, animData in ipairs(animationList) do
        self:Tween(
            animData.object,
            animData.properties,
            animData.duration,
            animData.easingStyle,
            animData.easingDirection,
            animData.preset
        )
    end
end

-- Emergency stop all animations (for performance)
function AnimationManager:StopAllAnimations()
    for _, animData in pairs(activeAnimations) do
        if animData.tween then
            animData.tween:Cancel()
        end
    end
    
    activeAnimations = {}
    animationQueue = {}
    
    _G.CensuraG.Logger:warn("Emergency animation stop executed")
end

return AnimationManager
