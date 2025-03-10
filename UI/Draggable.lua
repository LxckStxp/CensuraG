-- UI/Draggable.lua: Enhanced dragging functionality
local Draggable = {}
local UserInputService = game:GetService("UserInputService")
local logger = _G.CensuraG.Logger
local EventManager = _G.CensuraG.EventManager
local ErrorHandler = _G.CensuraG.ErrorHandler

-- Create a new draggable handler
function Draggable.new(element, dragRegion, options)
    if not element then
        logger:error("Cannot create Draggable with nil element")
        return nil
    end
    
    options = options or {}
    
    local self = {
        Element = element,
        DragRegion = dragRegion or element,
        Dragging = false,
        DragStart = nil,
        StartPos = nil,
        Connections = {},
        Bounds = options.Bounds,
        OnDragStart = options.OnDragStart,
        OnDragEnd = options.OnDragEnd,
        OnDrag = options.OnDrag
    }
    
    -- Handle input changes (mouse movement)
    table.insert(self.Connections, EventManager:Connect(
        UserInputService.InputChanged,
        function(input)
            if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - self.DragStart
                local newX = self.StartPos.X.Offset + delta.X
                local newY = self.StartPos.Y.Offset + delta.Y
                
                -- Apply bounds if specified
                if self.Bounds then
                    newX = math.clamp(newX, self.Bounds.MinX or 0, self.Bounds.MaxX or math.huge)
                    newY = math.clamp(newY, self.Bounds.MinY or 0, self.Bounds.MaxY or math.huge)
                else
                    -- Default bounds to screen edges
                    local screenGui = _G.CensuraG.ScreenGui
                    if screenGui and screenGui.AbsoluteSize then
                        newX = math.clamp(newX, 0, screenGui.AbsoluteSize.X - element.Size.X.Offset)
                        newY = math.clamp(newY, 0, screenGui.AbsoluteSize.Y - element.Size.Y.Offset)
                    end
                end
                
                self.Element.Position = UDim2.new(0, newX, 0, newY)
                
                -- Call the drag callback if provided
                if self.OnDrag then
                    self.OnDrag(newX, newY, delta)
                end
            end
        end
    ))
    
    -- Handle drag start
    table.insert(self.Connections, EventManager:Connect(
        self.DragRegion.InputBegan,
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                self.Dragging = true
                self.DragStart = input.Position
                self.StartPos = self.Element.Position
                
                -- Bring window to front if it's part of a window
                if self.Element.Parent and _G.CensuraG.WindowManager then
                    ErrorHandler:TryCatch(function()
                        _G.CensuraG.WindowManager:BringToFront(self.Element.Parent)
                    end, "Failed to bring window to front")
                end
                
                -- Call the drag start callback if provided
                if self.OnDragStart then
                    self.OnDragStart()
                end
                
                logger:debug("Started dragging %s", tostring(self.Element))
            end
        end
    ))
    
    -- Handle drag end
    table.insert(self.Connections, EventManager:Connect(
        self.DragRegion.InputEnded,
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and self.Dragging then
                self.Dragging = false
                
                -- Call the drag end callback if provided
                if self.OnDragEnd then
                    self.OnDragEnd(self.Element.Position.X.Offset, self.Element.Position.Y.Offset)
                end
                
                logger:debug("Stopped dragging %s", tostring(self.Element))
            end
        end
    ))
    
    -- Handle global mouse release (in case mouse is released outside the drag region)
    table.insert(self.Connections, EventManager:Connect(
        UserInputService.InputEnded,
        function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and self.Dragging then
                self.Dragging = false
                
                -- Call the drag end callback if provided
                if self.OnDragEnd then
                    self.OnDragEnd(self.Element.Position.X.Offset, self.Element.Position.Y.Offset)
                end
                
                logger:debug("Stopped dragging %s (global release)", tostring(self.Element))
            end
        end
    ))
    
    -- Set bounds method
    function self:SetBounds(minX, minY, maxX, maxY)
        self.Bounds = {
            MinX = minX,
            MinY = minY,
            MaxX = maxX,
            MaxY = maxY
        }
        logger:debug("Set bounds for draggable: (%d,%d) to (%d,%d)", minX, minY, maxX, maxY)
    end
    
    -- Clean up method
    function self:Destroy()
        for _, connection in ipairs(self.Connections) do
            connection:Disconnect()
        end
        self.Connections = {}
        logger:debug("Draggable destroyed for %s", tostring(self.Element))
    end
    
    return self
end

return Draggable
