-- Elements/TextButton.lua
-- Simplified text button using enhanced UIElement base

local TextButton = {}
TextButton.__index = TextButton
setmetatable(TextButton, { __index = _G.CensuraG.UIElement })

function TextButton.new(options)
    options = options or {}
    
    -- Set default properties for TextButton
    options.styleType = "TextButton"
    options.text = options.text or "Button"
    
    -- Create the base element
    local self = _G.CensuraG.UIElement.new(options.parent, options)
    
    -- Change the instance to a TextButton
    local textButton = Instance.new("TextButton")
    textButton.Name = self.Instance.Name
    textButton.Size = self.Instance.Size
    textButton.Position = self.Instance.Position
    textButton.ZIndex = self.Instance.ZIndex
    textButton.Parent = self.Instance.Parent
    textButton.Text = options.text
    textButton.Font = _G.CensuraG.Styling.Fonts.Primary
    textButton.TextSize = _G.CensuraG.Styling.TextSizes.Button
    
    -- Clean up original frame
    self.Instance:Destroy()
    self.Instance = textButton
    
    -- Apply styling
    _G.CensuraG.Styling:Apply(self.Instance, "TextButton")
    
    -- Set up hover effect
    self:AddHoverEffect({
        BackgroundTransparency = _G.CensuraG.Styling.Transparency.ElementBackground - 0.2
    }, {
        BackgroundTransparency = _G.CensuraG.Styling.Transparency.ElementBackground
    })
    
    -- Set up click handler
    if options.onClick then
        self:OnClick(options.onClick, { bounce = true })
    end
    
    -- Set metatable for this instance
    return setmetatable(self, TextButton)
end

-- Set enabled state
function TextButton:SetEnabled(enabled)
    if self.IsDestroyed then return self end
    
    self.Instance.Active = enabled
    self.Instance.TextTransparency = enabled and 0 or 0.5
    self.Instance.BackgroundTransparency = enabled 
        and _G.CensuraG.Styling.Transparency.ElementBackground 
        or _G.CensuraG.Styling.Transparency.ElementBackground + 0.5
    
    return self
end

-- Set text content
function TextButton:SetText(text)
    if self.IsDestroyed then return self end
    
    self.Instance.Text = text or ""
    return self
end

return TextButton
