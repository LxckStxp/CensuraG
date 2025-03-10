-- Draggable.lua: Robust dragging API with persistent connections
local Draggable = {}
local UserInputService = game:GetService("UserInputService")

function Draggable.new(element, dragRegion)
    local self = {}
    self.Element = element
    self.DragRegion = dragRegion or element
    self.Dragging = false
    self.DragStart = nil
    self.StartPos = nil

    -- Persistent mouse tracking
    local connection = UserInputService.InputChanged:Connect(function(input)
        if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - self.DragStart
            local newPos = UDim2.new(0, self.StartPos.X.Offset + delta.X, 0, self.StartPos.Y.Offset + delta.Y)
            self.Element.Position = newPos
        end
    end)

    self.DragRegion.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = true
            self.DragStart = input.Position
            self.StartPos = self.Element.Position
        end
    end)

    self.DragRegion.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end)

    function self:Destroy()
        connection:Disconnect()
    end

    return self
end

return Draggable
