-- UI/Draggable.lua
-- Optimized draggable functionality

local Draggable = {}
local UserInputService = game:GetService("UserInputService")
local logger = _G.CensuraG.Logger
local EventManager = _G.CensuraG.EventManager
local ErrorHandler = _G.CensuraG.ErrorHandler

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
        OnDrag = options.OnDrag,
        Destroyed = false
    }
    
    -- Single input changed handler for drag movement
    self.Connections.inputChanged = EventManager:Connect(UserInputService.InputChanged, function(input)
        if not self.Dragging or input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        
        local delta = input.Position - self.DragStart
        local newX = self.StartPos.X.Offset + delta.X
        local newY = self.StartPos.Y.Offset + delta.Y
        
        -- Apply bounds if specified
        if self.Bounds then
            newX = math.clamp(newX, self.Bounds.MinX or 0, self.Bounds.MaxX or math.huge)
            newY = math.clamp(newY, self.Bounds.MinY or 0, self.Bounds.MaxY or math.huge)
        else
            -- Default bounds to screen edges
            local gui = _G.CensuraG.ScreenGui
            if gui then 
                newX = math.clamp(newX, 0, gui.AbsoluteSize.X - element.Size.X.Offset)
                newY = math.clamp(newY, 0, gui.AbsoluteSize.Y - element.Size.Y.Offset)
            end
        end
        
        -- Apply the new position
        self.Element.Position = UDim2.new(0, newX, 0, newY)
        
        -- Call the drag callback if provided
        if self.OnDrag then 
            ErrorHandler:TryCatch(function() 
                self.OnDrag(newX, newY, delta) 
            end, "Error in drag callback")
        end
    end)
    
    -- Start dragging when mouse down on drag region
    self.Connections.inputBegan = EventManager:Connect(self.DragRegion.InputBegan, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        
        self.Dragging = true
        self.DragStart = input.Position
        self.StartPos = self.Element.Position
        
        -- Try to bring window to front if applicable
        ErrorHandler:TryCatch(function() 
            if _G.CensuraG.WindowManager then
                _G.CensuraG.WindowManager:BringToFront(self.Element.Parent)
            end
        end, "Failed to bring window to front")
        
        -- Call the drag start callback if provided
        if self.OnDragStart then 
            ErrorHandler:TryCatch(self.OnDragStart, "Error in drag start callback")
        end
    end)
    
    -- Stop dragging on mouse up (local)
    self.Connections.inputEnded = EventManager:Connect(self.DragRegion.InputEnded, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 or not self.Dragging then return end
        
        self:EndDrag()
    end)
    
    -- Stop dragging on mouse up (global - fallback)
    self.Connections.globalInputEnded = EventManager:Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 or not self.Dragging then return end
        
        self:EndDrag()
    end)
    
    -- Define end drag method
    function self:EndDrag()
        if not self.Dragging then return end
        
        self.Dragging = false
        
        -- Call the drag end callback if provided
        if self.OnDragEnd then 
            ErrorHandler:TryCatch(function()
                self.OnDragEnd(self.Element.Position.X.Offset, self.Element.Position.Y.Offset)
            end, "Error in drag end callback")
        end
    end
    
    -- Set bounds method
    function self:SetBounds(minX, minY, maxX, maxY)
        self.Bounds = { MinX = minX, MinY = minY, MaxX = maxX, MaxY = maxY }
        return self
    end
    
    -- Cleanup method
    function self:Destroy()
        if self.Destroyed then return end
        self.Destroyed = true
        
        for name, conn in pairs(self.Connections) do
            conn:Disconnect()
        end
        self.Connections = {}
        
        logger:debug("Draggable destroyed for %s", tostring(self.Element))
    end
    
    return self
end

return Draggable
