-- UI/Draggable.lua
local Draggable = {}
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local logger = _G.CensuraG.Logger
local EventManager = _G.CensuraG.EventManager
local ErrorHandler = _G.CensuraG.ErrorHandler
local Animation = _G.CensuraG.Animation

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
        LastPosition = nil,
        Velocity = Vector2.new(0, 0),
        Connections = {},
        Bounds = options.Bounds,
        OnDragStart = options.OnDragStart,
        OnDragEnd = options.OnDragEnd,
        OnDrag = options.OnDrag,
        DragThreshold = options.DragThreshold or 0, -- Removed threshold to start immediately
        InertiaEnabled = options.InertiaEnabled ~= false,
        Friction = options.Friction or 0.9
    }

    local function updatePosition(newX, newY)
        if self.Bounds then
            newX = math.clamp(newX, self.Bounds.MinX or 0, self.Bounds.MaxX or math.huge)
            newY = math.clamp(newY, self.Bounds.MinY or 0, self.Bounds.MaxY or math.huge)
        else
            local gui = _G.CensuraG.ScreenGui
            if gui then
                local taskbarHeight = (_G.CensuraG.Taskbar and _G.CensuraG.Taskbar.Height) or 0
                newX = math.clamp(newX, 0, gui.AbsoluteSize.X - element.Size.X.Offset)
                newY = math.clamp(newY, 0, gui.AbsoluteSize.Y - element.Size.Y.Offset - taskbarHeight)
            end
        end
        self.Element.Position = UDim2.new(0, newX, 0, newY)
        if self.OnDrag then self.OnDrag(newX, newY) end
    end

    table.insert(self.Connections, EventManager:Connect(UserInputService.InputChanged, function(input)
        if self.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - self.DragStart
            local newX = self.StartPos.X.Offset + delta.X
            local newY = self.StartPos.Y.Offset + delta.Y
            updatePosition(newX, newY)
            self.LastPosition = input.Position
            self.Velocity = (input.Position - (self.LastPosition or input.Position)) * 60
        end
    end))

    table.insert(self.Connections, EventManager:Connect(self.DragRegion.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.DragStart = input.Position
            self.StartPos = self.Element.Position
            self.LastPosition = input.Position
            self.Velocity = Vector2.new(0, 0)
            self.Dragging = true
            ErrorHandler:TryCatch(function()
                if _G.CensuraG.WindowManager then
                    _G.CensuraG.WindowManager:BringToFront(self.Element.Parent)
                end
            end, "Failed to bring window to front")
            if self.OnDragStart then self.OnDragStart() end
            logger:debug("Started dragging %s", tostring(self.Element))
        end
    end))

    table.insert(self.Connections, EventManager:Connect(self.DragRegion.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self.Dragging then
            self.Dragging = false
            local finalX, finalY = self.Element.Position.X.Offset, self.Element.Position.Y.Offset
            if self.InertiaEnabled and self.Velocity.Magnitude > 10 then
                local inertiaConnection
                inertiaConnection = RunService.RenderStepped:Connect(function(dt)
                    self.Velocity = self.Velocity * self.Friction
                    finalX = finalX + self.Velocity.X * dt
                    finalY = finalY + self.Velocity.Y * dt
                    updatePosition(finalX, finalY)
                    if self.Velocity.Magnitude < 1 then
                        inertiaConnection:Disconnect()
                        if _G.CensuraG.WindowManager then
                            _G.CensuraG.WindowManager:SnapWindow(self.Element.Parent)
                        end
                        if self.OnDragEnd then self.OnDragEnd(finalX, finalY) end
                        logger:debug("Inertia stopped for %s at (%d, %d)", tostring(self.Element), finalX, finalY)
                    end
                end)
                table.insert(self.Connections, inertiaConnection)
            else
                if _G.CensuraG.WindowManager then
                    _G.CensuraG.WindowManager:SnapWindow(self.Element.Parent)
                end
                if self.OnDragEnd then self.OnDragEnd(finalX, finalY) end
                logger:debug("Stopped dragging %s", tostring(self.Element))
            end
        end
    end))

    function self:SetBounds(minX, minY, maxX, maxY)
        self.Bounds = { MinX = minX, MinY = minY, MaxX = maxX, MaxY = maxY }
        logger:debug("Set draggable bounds for %s", tostring(self.Element))
    end

    function self:SetInertia(enabled)
        self.InertiaEnabled = enabled
        logger:debug("Inertia %s for %s", enabled and "enabled" or "disabled", tostring(self.Element))
    end

    function self:SetFriction(friction)
        self.Friction = math.clamp(friction, 0.1, 0.99)
        logger:debug("Set friction to %.2f for %s", self.Friction, tostring(self.Element))
    end

    function self:SmoothMoveTo(x, y, duration)
        duration = duration or 0.2
        Animation:Tween(self.Element, { Position = UDim2.new(0, x, 0, y) }, duration / (_G.CensuraG.Config and _G.CensuraG.Config.AnimationSpeed or 1), nil, nil, function()
            if _G.CensuraG.WindowManager then
                _G.CensuraG.WindowManager:SnapWindow(self.Element.Parent)
            end
            if self.OnDragEnd then self.OnDragEnd(x, y) end
        end)
        logger:debug("Smooth move %s to (%d, %d)", tostring(self.Element), x, y)
    end

    function self:Destroy()
        for _, conn in ipairs(self.Connections) do conn:Disconnect() end
        self.Connections = {}
        self.Velocity = Vector2.new(0, 0)
        logger:debug("Draggable destroyed for %s", tostring(self.Element))
    end

    return self
end

return Draggable
