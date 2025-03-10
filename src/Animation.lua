-- Animation.lua: Simple animation utilities with improved consistency
local Animation = {}
local TweenService = game:GetService("TweenService")
local logger = _G.CensuraG.Logger

Animation.TweenQueue = {}

function Animation:Tween(element, properties, duration, callback)
    local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(element, tweenInfo, properties)
    table.insert(self.TweenQueue, {tween = tween, callback = callback})
    logger:debug("Queued tween for element: %s, Properties: %s", tostring(element), tostring(properties))

    tween.Completed:Connect(function()
        local index = table.find(self.TweenQueue, {tween = tween})
        if index then
            table.remove(self.TweenQueue, index)
            if callback then
                pcall(callback)
                logger:debug("Completed tween for element: %s", tostring(element))
            end
        end
    end)
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

function Animation:WaitForAnimations()
    while #self.TweenQueue > 0 do
        wait(0.1) -- Wait for animations to complete
    end
    logger:debug("All animations completed")
end

return Animation
