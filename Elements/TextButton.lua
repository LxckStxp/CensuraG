-- Elements/TextButton.lua
-- Enhanced button element

local TextButton = setmetatable({}, { __index = _G.CensuraG.UIElement })
TextButton.__index = TextButton

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager
local logger = _G.CensuraG.Logger

function TextButton.new(parent, text, x, y, width, height, callback, options)
    options = options or {}
    width = width or 120
    height = height or 30
    
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width + (options.NoLabel and 0 or 80), 0, height),
        BackgroundTransparency = 1,
        ZIndex = parent.Instance.ZIndex + 1,
        Name = "TextButton_" .. (text or "Button")
    })
    
    local label = options.NoLabel and nil or Utilities.createInstance("TextLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 60, 0, height),
        Text = text,
        ZIndex = frame.ZIndex + 1,
        Name = "Label"
    })
    if label then Styling:Apply(label, "TextLabel") end
    
    local button = Utilities.createInstance("TextButton", {
        Parent = frame,
        Position = UDim2.new(0, options.NoLabel and 0 or 65, 0, 0),
        Size = UDim2.new(0, options.NoLabel and width or (width - 65), 0, height),
        Text = options.NoLabel and text or "",
        ZIndex = frame.ZIndex + 1,
        Name = "Button"
    })
    Styling:Apply(button, "TextButton")
    Animation:HoverEffect(button, {
        BackgroundTransparency = Styling.Transparency.ElementBackground - 0.2,
        Size = UDim2.new(0, button.Size.X.Offset * 1.05, 0, button.Size.Y.Offset * 1.05)
    }, {
        BackgroundTransparency = Styling.Transparency.ElementBackground,
        Size = button.Size
    })
    
    local self = setmetatable({
        Instance = frame,
        Label = label,
        Button = button,
        Callback = callback,
        Enabled = true,
        Options = options,
        Connections = {}
    }, TextButton)
    
    table.insert(self.Connections, EventManager:Connect(button.MouseButton1Click, function()
        if not self.Enabled then return end
        Animation:Elastic(button, { Size = UDim2.new(0, button.Size.X.Offset * 1.1, 0, button.Size.Y.Offset * 1.1) }, 0.3 / _G.CensuraG.Config.AnimationSpeed, function()
            Animation:Tween(button, { Size = button.Size }, 0.1 / _G.CensuraG.Config.AnimationSpeed)
        end)
        if self.Callback then self.Callback() end
        EventManager:FireEvent("ButtonClicked", self)
    end))
    
    function self:SetEnabled(enabled)
        self.Enabled = enabled
        button.BackgroundTransparency = enabled and Styling.Transparency.ElementBackground or (Styling.Transparency.ElementBackground + 0.4)
        button.TextTransparency = enabled and 0 or 0.4
        return self
    end
    
    function self:SetText(newText)
        if self.Label then self.Label.Text = newText else self.Button.Text = newText end
        return self
    end
    
    function self:Destroy()
        for _, conn in ipairs(self.Connections) do conn:Disconnect() end
        self.Connections = {}
        if self.Instance then self.Instance:Destroy() end
        logger:info("TextButton destroyed: %s", text or "Button")
    end
    
    return self
end

return TextButton
