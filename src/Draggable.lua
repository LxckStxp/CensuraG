function Draggable.new(element, dragRegion)
    local self = {}
    self.Element = element
    self.DragRegion = dragRegion or element
    self.Dragging = false
    self.DragStart = nil
    self.StartPos = nil

    local screenGui = _G.CensuraG.ScreenGui
    local connection = UserInputService.InputChanged:Connect(function(input)
        if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - self.DragStart
            local newX = math.clamp(self.StartPos.X.Offset + delta.X, 0, screenGui.AbsoluteSize.X - element.Size.X.Offset)
            local newY = math.clamp(self.StartPos.Y.Offset + delta.Y, 0, screenGui.AbsoluteSize.Y - element.Size.Y.Offset)
            self.Element.Position = UDim2.new(0, newX, 0, newY)
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
