-- Elements/ImageLabel.lua
-- Image display component

local ImageLabel = setmetatable({}, { __index = _G.CensuraG.UIElement })
ImageLabel.__index = ImageLabel

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local Animation = _G.CensuraG.Animation
local EventManager = _G.CensuraG.EventManager
local logger = _G.CensuraG.Logger

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
    
    -- Create the image
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
    
    -- Create an invisible click overlay button (since ClickDetector isn’t valid for Gui objects)
    local clickDetector = Utilities.createInstance("TextButton", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = image.ZIndex + 1,
        Name = "ClickDetector"
    })
    
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
    
    local self = setmetatable({
        Instance = frame,
        Image = image,
        Caption = caption,
        ClickDetector = clickDetector,  -- New click detector is stored here.
        Connections = {}
    }, ImageLabel)
    
    function self:SetImage(url)
        if not url then return self end
        
        Animation:Tween(self.Image, { ImageTransparency = 1 }, 0.2, nil, nil, function()
            self.Image.Image = url
            Animation:Tween(self.Image, { ImageTransparency = options.ImageTransparency or 0 }, 0.2)
        end)
        logger:debug("Updated image to: %s", tostring(url))
        return self
    end
    
    function self:SetCaption(text)
        if not self.Caption then
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
        logger:debug("Set caption to: %s", text or "")
        return self
    end
    
    function self:OnClick(callback)
        if not callback then return self end
        
        -- Disconnect any existing click connection
        for i, conn in ipairs(self.Connections) do
            if conn.Name == "ClickConnection" then
                conn.Connection:Disconnect()
                table.remove(self.Connections, i)
                break
            end
        end
        
        local connection = EventManager:Connect(self.ClickDetector.MouseButton1Click, function()
            local success, err = pcall(callback)
            if not success then
                logger:warn("ImageLabel click callback error: %s", err)
            end
        end)
        table.insert(self.Connections, { Name = "ClickConnection", Connection = connection })
        logger:debug("Click handler added to ImageLabel")
        return self
    end
    
    function self:AddHoverEffect(scale)
        scale = scale or 1.1
        
        for i, conn in ipairs(self.Connections) do
            if conn.Name == "HoverEnter" or conn.Name == "HoverLeave" then
                conn.Connection:Disconnect()
                table.remove(self.Connections, i)
            end
        end
        
        local enterConn = EventManager:Connect(self.ClickDetector.MouseEnter, function()
            Animation:Tween(self.Image, { Size = UDim2.new(scale, 0, scale, 0) }, 0.2)
        end)
        local leaveConn = EventManager:Connect(self.ClickDetector.MouseLeave, function()
            Animation:Tween(self.Image, { Size = UDim2.new(1, 0, 1, 0) }, 0.2)
        end)
        table.insert(self.Connections, { Name = "HoverEnter", Connection = enterConn })
        table.insert(self.Connections, { Name = "HoverLeave", Connection = leaveConn })
        logger:debug("Hover effect added to ImageLabel")
        return self
    end
    
    function self:Destroy()
        for _, conn in ipairs(self.Connections) do
            conn.Connection:Disconnect()
        end
        self.Connections = {}
        if self.Instance then self.Instance:Destroy() end
        logger:info("ImageLabel destroyed")
    end
    
    return self
end

return ImageLabel
