-- Draggable.lua: Robust dragging API with screen constraints
local Draggable = {}
local UserInputService = game:GetService("UserInputService")
local logger = _G.CensuraG.Logger

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
            logger:debug("Dragging %s to: (%d, %d)", tostring(element), newX, newY)
        end
    end)

    self.DragRegion.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = true
            self.DragStart = input.Position
            self.StartPos = self.Element.Position
            _G.CensuraG.WindowManager:BringToFront(self.Element.Parent)
        end
    end)

    self.DragRegion.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end)

    function self:Destroy()
        connection:Disconnect()
        logger:debug("Draggable destroyed for %s", tostring(element))
    end

    return self
end

return Draggable
