-- Draggable.lua: Robust and sophisticated dragging API
local Draggable = {}
local UserInputService = game:GetService("UserInputService")

-- Draggable object constructor
function Draggable.new(element, options)
    local self = {}
    self.Element = element
    self.Dragging = false
    self.DragStart = nil
    self.StartPos = nil
    
    -- Options with defaults
    options = options or {}
    self.DragRegion = options.DragRegion or element
    self.AxisLock = options.AxisLock or "None" -- "X", "Y", or "None"
    self.Bounds = options.Bounds or nil -- {MinX, MaxX, MinY, MaxY} or nil
    self.OnDragStart = options.OnDragStart
    self.OnDrag = options.OnDrag
    self.OnDragEnd = options.OnDragEnd
    
    -- Persistent connection for global mouse tracking
    local connection = UserInputService.InputChanged:Connect(function(input)
        if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - self.DragStart
            local newX = self.StartPos.X.Offset + delta.X
            local newY = self.StartPos.Y.Offset + delta.Y
            
            -- Apply axis lock
            if self.AxisLock == "X" then
                newY = self.StartPos.Y.Offset
            elseif self.AxisLock == "Y" then
                newX = self.StartPos.X.Offset
            end
            
            -- Apply bounds
            if self.Bounds then
                newX = math.clamp(newX, self.Bounds.MinX, self.Bounds.MaxX)
                newY = math.clamp(newY, self.Bounds.MinY, self.Bounds.MaxY)
            end
            
            local newPos = UDim2.new(0, newX, 0, newY)
            self.Element.Position = newPos
            if self.OnDrag then
                self.OnDrag(self.Element, newPos)
            end
        end
    end)
    
    -- Start dragging
    self.DragRegion.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = true
            self.DragStart = input.Position
            self.StartPos = self.Element.Position
            if self.OnDragStart then
                self.OnDragStart(self.Element)
            end
        end
    end)
    
    -- End dragging
    self.DragRegion.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
            if self.OnDragEnd then
                self.OnDragEnd(self.Element)
            end
        end
    end)
    
    -- Cleanup method
    function self:Destroy()
        connection:Disconnect()
    end
    
    return self
end

return Draggable
