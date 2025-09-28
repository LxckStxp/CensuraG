-- CensuraG/src/ui/AnimationManager.lua (updated for smoother animations)
local AnimationManager = {}
AnimationManager.__index = AnimationManager

local TweenService = game:GetService("TweenService")

function AnimationManager:Tween(object, properties, duration, easingStyle, easingDirection)
    -- Check if object is valid for tweening
    if not object or typeof(object) ~= "Instance" then
        _G.CensuraG.Logger:error("Cannot tween invalid object: " .. tostring(object))
        return
    end
    
    -- Make sure properties is a table
    if type(properties) ~= "table" then
        _G.CensuraG.Logger:error("Properties must be a table")
        return
    end
    
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    duration = duration or 0.2 -- Match CensuraDev timing
    
    -- Safety check for valid properties
    local validProperties = {}
    for prop, value in pairs(properties) do
        -- Only include properties that exist on the object
        if pcall(function() return object[prop] ~= nil end) then
            validProperties[prop] = value
        else
            _G.CensuraG.Logger:warn("Property " .. prop .. " doesn't exist on " .. object.Name)
        end
    end
    
    -- Only proceed if we have valid properties to tween
    if next(validProperties) then
        local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
        local tween = TweenService:Create(object, tweenInfo, validProperties)
        tween:Play()
        
        return tween
    else
        _G.CensuraG.Logger:warn("No valid properties to tween for " .. object.Name)
    end
end

-- Add button feedback animations
function AnimationManager:ButtonPress(button, stroke)
    self:Tween(button, {BackgroundTransparency = 0.6}, 0.1)
    if stroke then
        self:Tween(stroke, {Transparency = 0.4}, 0.1)
    end
end

function AnimationManager:ButtonRelease(button, stroke)
    self:Tween(button, {BackgroundTransparency = 0.8}, 0.2)
    if stroke then
        self:Tween(stroke, {Transparency = 0.6}, 0.2)
    end
end

-- Add hover effects
function AnimationManager:ApplyHoverState(object, stroke)
    self:Tween(object, {BackgroundTransparency = object.BackgroundTransparency - 0.1}, 0.2)
    if stroke then
        self:Tween(stroke, {Transparency = 0.4}, 0.2)
    end
end

function AnimationManager:RemoveHoverState(object, stroke)
    self:Tween(object, {BackgroundTransparency = object.BackgroundTransparency + 0.1}, 0.2)
    if stroke then
        self:Tween(stroke, {Transparency = 0.6}, 0.2)
    end
end

return AnimationManager
