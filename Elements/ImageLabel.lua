-- Elements/ImageLabel.lua: Enhanced image display component
local ImageLabel = setmetatable({}, {__index = _G.CensuraG.UIElement})
ImageLabel.__index = ImageLabel

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager
local logger = _G.CensuraG.Logger

-- Create a new image label
function ImageLabel.new(parent, imageUrl, x, y, width, height, options)
    if not parent or not parent.Instance then
        logger:error("Invalid parent for ImageLabel")
        return nil
    end
    
    options = options or {}
    width = width or 50
    height = height or 50
    
    -- Create main frame
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x or 0, 0, y or 0),
        Size = UDim2.new(0, width, 0, height),
        BackgroundTransparency = 1,
        ZIndex = parent.Instance.ZIndex + 1,
        Name = "ImageLabel_" .. (options.Name or "Image")
    })
    
    -- Create image
    local image = Utilities.createInstance("ImageLabel", {
        Parent = frame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = options.BackgroundTransparency or 1,
        Image = imageUrl or "",
        ImageTransparency = options.ImageTransparency or 0,
        ScaleType = options.ScaleType or Enum.ScaleType.Fit,
        ZIndex = frame.ZIndex + 1,
        Name = "Image"
    })
    Styling:Apply(image, "ImageLabel")
    
    -- Apply corner rounding if specified
    if options.CornerRadius then
        local corner = Utilities.createInstance("UICorner", {
            Parent = image,
            CornerRadius = UDim.new(0, options.CornerRadius)
        })
    end
    
    -- Create caption if specified
    local caption = nil
    if options.Caption then
        caption = Utilities.createInstance("TextLabel", {
            Parent = frame,
            Position = UDim2.new(0, 0, 1, 5),
            Size = UDim2.new(1, 0, 0, 20),
            Text = options.Caption,
            BackgroundTransparency = 1,
            ZIndex = frame.ZIndex + 1,
            Name = "Caption"
        })
        Styling:Apply(caption, "TextLabel")
    end
    
    -- Create an invisible button over the image for click detection
    local clickDetector = Utilities.createInstance("TextButton", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = frame.ZIndex + 2,
        Name = "ClickDetector"
    })
    
    -- Create self object
    local self = setmetatable({
        Instance = frame,
        Image = image,
        Caption = caption,
        ClickDetector = clickDetector,
        Options = options,
        Connections = {}
    }, ImageLabel)
    
    -- Set image method
    function self:SetImage(url)
        if not url then return self end
        
        -- Fade out current image
        Animation:Tween(self.Image, {ImageTransparency = 1}, 0.2, nil, nil, function()
            -- Set new image and fade in
            self.Image.Image = url
            Animation:Tween(self.Image, {ImageTransparency = options.ImageTransparency or 0}, 0.2)
        end)
        
        logger:debug("ImageLabel updated to: %s", url)
        return self
    end
    
    -- Set caption method
    function self:SetCaption(text)
        if not self.Caption then
            -- Create caption if it doesn't exist
            self.Caption = Utilities.createInstance("TextLabel", {
                Parent = self.Instance,
                Position = UDim2.new(0, 0, 1, 5),
                Size = UDim2.new(1, 0, 0, 20),
                Text = text or "",
                BackgroundTransparency = 1,
                ZIndex = self.Instance.ZIndex + 1,
                Name = "Caption"
            })
            Styling:Apply(self.Caption, "TextLabel")
        else
            self.Caption.Text = text or ""
        end
        
        logger:debug("ImageLabel caption set to: %s", text or "")
        return self
    end
    
    -- Set scale type method
    function self:SetScaleType(scaleType)
        self.Image.ScaleType = scaleType
        logger:debug("ImageLabel scale type set to: %s", tostring(scaleType))
        return self
    end
    
    -- Set size method
    function self:SetSize(width, height)
        self.Instance.Size = UDim2.new(0, width, 0, height)
        logger:debug("ImageLabel size set to: %d x %d", width, height)
        return self
    end
    
    -- Add click handler
    function self:OnClick(callback)
        if not callback then return self end
        
        -- Use the click detector instead of the image directly
        -- Disconnect any existing connections first
        for i, conn in ipairs(self.Connections) do
            if conn.Name == "ClickConnection" then
                conn.Connection:Disconnect()
                table.remove(self.Connections, i)
                break
            end
        end
        
        -- Connect new click event
        local connection = EventManager:Connect(
            self.ClickDetector.MouseButton1Click,
            function()
                local success, result = pcall(callback)
                if not success then
                    logger:warn("ImageLabel click callback error: %s", result)
                end
            end
        )
        
        -- Store connection with a name for later reference
        table.insert(self.Connections, {Name = "ClickConnection", Connection = connection})
        
        logger:debug("ImageLabel click handler added")
        return self
    end
    
    -- Add hover effect
    function self:AddHoverEffect(scale)
        scale = scale or 1.1
        
        -- Clean up any existing hover connections
        for i, conn in ipairs(self.Connections) do
            if conn.Name == "HoverEnter" or conn.Name == "HoverLeave" then
                conn.Connection:Disconnect()
                table.remove(self.Connections, i)
            end
        end
        
        -- Add new hover connections
        local enterConnection = EventManager:Connect(
            self.ClickDetector.MouseEnter,
            function()
                Animation:Tween(self.Image, {
                    Size = UDim2.new(scale, 0, scale, 0),
                    Position = UDim2.new((1-scale)/2, 0, (1-scale)/2, 0)
                }, 0.2)
            end
        )
        
        local leaveConnection = EventManager:Connect(
            self.ClickDetector.MouseLeave,
            function()
                Animation:Tween(self.Image, {
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0)
                }, 0.2)
            end
        )
        
        -- Store connections with names
        table.insert(self.Connections, {Name = "HoverEnter", Connection = enterConnection})
        table.insert(self.Connections, {Name = "HoverLeave", Connection = leaveConnection})
        
        logger:debug("ImageLabel hover effect added")
        return self
    end
    
    -- Clean up resources
    function self:Destroy()
        for _, connData in ipairs(self.Connections) do
            connData.Connection:Disconnect()
        end
        self.Connections = {}
        
        if self.Instance then
            self.Instance:Destroy()
        end
        
        logger:info("ImageLabel destroyed")
    end
    
    -- Example of how to use the image label
    if options.ShowExample then
        logger:debug([[
Example usage:
local image = CensuraG.ImageLabel.new(window, "rbxassetid://123456789", 10, 50, 100, 100, {
    Caption = "My Image",
    ScaleType = Enum.ScaleType.Fit,
    CornerRadius = 8
})

-- Change image with fade effect
image:SetImage("rbxassetid://987654321")

-- Add click handler
image:OnClick(function()
    print("Image clicked!")
end)

-- Add hover effect
image:AddHoverEffect(1.1)
]])
    end
    
    return self
end

return ImageLabel
