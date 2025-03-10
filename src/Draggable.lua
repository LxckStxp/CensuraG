-- Draggable.lua: API for making UI elements draggable (improved for fast dragging)
local Draggable = {}
local UserInputService = game:GetService("UserInputService")

function Draggable:MakeDraggable(element, dragRegion, onDragStart, onDrag, onDragEnd)
    local dragging = false
    local dragStart, startPos
    
    dragRegion = dragRegion or element
    
    dragRegion.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = element.Position
            if onDragStart then onDragStart(element) end
        end
    end)
    
    -- Use global InputChanged to track mouse movement reliably
    local connection
    connection = UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
            element.Position = newPos
            if onDrag then onDrag(element, newPos) end
        end
    end)
    
    dragRegion.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            connection:Disconnect() -- Clean up
            if onDragEnd then onDragEnd(element) end
        end
    end)
end

return Draggable
