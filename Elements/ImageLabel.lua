-- Elements/ImageLabel.lua
-- Simplified image label using enhanced UIElement base

local ImageLabel = {}
ImageLabel.__index = ImageLabel
setmetatable(ImageLabel, { __index = _G.CensuraG.UIElement })

function ImageLabel.new(options)
    options = options or {}
    
    -- Set default properties for ImageLabel
    options.width = options.width or 50
    options.height = options.height or 50
    options.imageUrl = options.imageUrl or ""
    options.scaleType = options.scaleType or Enum.ScaleType.Fit
    options.imageTransparency = options.imageTransparency or 0
    options.styleType = "ImageLabel"
    
    -- Create the base element
    local self = _G.CensuraG.UIElement.new(options.parent, options)
    
    -- Create the image
    local image = Instance.new("ImageLabel")
    image.Name = "Image"
    image.Size = UDim2.new(1, 0, 1, 0)
    image.Position = UDim2.new(0, 0, 0, 0)
    image.BackgroundTransparency = options.backgroundTransparency or 1
    image.Image = options.imageUrl
    image.ImageTransparency = options.imageTransparency
    image.ScaleType = options.scaleType
    image.ZIndex = self.Instance.ZIndex + 1
    image.Parent = self.Instance
    _G.CensuraG.Styling:Apply(image, "ImageLabel")
    
    -- Create caption if specified
    local caption = nil
    if options.caption then
        caption = Instance.new("TextLabel")
        caption.Name = "Caption"
        caption.Size = UDim2.new(1, 0, 0, 20)
        caption.Position = UDim2.new(0, 0, 1, 5)
        caption.Text = options.caption
        caption.BackgroundTransparency = 1
        caption.ZIndex = self.Instance.ZIndex + 1
        caption.Parent = self.Instance
        _G.CensuraG.Styling:Apply(caption, "TextLabel")
    end
    
    -- Set up properties
    self.Image = image
    self.Caption = caption
    
    -- Set up click handler
    if options.onClick then
        self:OnClick(options.onClick)
    end
    
    -- Set up hover effect if needed
    if options.hoverScale then
        self:AddHoverEffect()
    end
    
    -- Set metatable for this instance
    return setmetatable(self, ImageLabel)
end

-- Set the image
function ImageLabel:SetImage(url)
    if self.IsDestroyed or not url then return self end
    
    _G.CensuraG.Animation:Tween(self.Image, { ImageTransparency = 1 }, 0.2, nil, nil, function()
        self.Image.Image = url
        _G.CensuraG.Animation:Tween(
            self.Image, 
            { ImageTransparency = self.Options.imageTransparency or 0 }, 
            0.2
        )
    end)
    
    return self
end

-- Set the caption
function ImageLabel:SetCaption(text)
    if self.IsDestroyed then return self end
    
    if not self.Caption then
        self.Caption = Instance.new("TextLabel")
        self.Caption.Name = "Caption"
        self.Caption.Size = UDim2.new(1, 0, 0, 20)
        self.Caption.Position = UDim2.new(0, 0, 1, 5)
        self.Caption.Text = text or ""
        self.Caption.BackgroundTransparency = 1
        self.Caption.ZIndex = self.Instance.ZIndex + 1
        self.Caption.Parent = self.Instance
        _G.CensuraG.Styling:Apply(self.Caption, "TextLabel")
    else
        self.Caption.Text = text or ""
    end
    
    return self
end

-- Add a hover effect with scaling
function ImageLabel:AddHoverEffect(scale)
    if self.IsDestroyed then return self end
    
    scale = scale or 1.1
    
    self.Image.MouseEnter:Connect(function()
        _G.CensuraG.Animation:Tween(self.Image, { Size = UDim2.new(scale, 0, scale, 0) }, 0.2)
    end)
    
    self.Image.MouseLeave:Connect(function()
        _G.CensuraG.Animation:Tween(self.Image, { Size = UDim2.new(1, 0, 1, 0) }, 0.2)
    end)
    
    return self
end

return ImageLabel
