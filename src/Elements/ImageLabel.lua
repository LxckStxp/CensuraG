-- Elements/ImageLabel.lua: Styled image label with modern miltech styling
local ImageLabel = setmetatable({}, {__index = _G.CensuraG.UIElement})
ImageLabel.__index = ImageLabel

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local logger = _G.CensuraG.Logger

function ImageLabel.new(parent, imageUrl, x, y, width, height, options)
    options = options or {}
    if not parent or not parent.Instance then
        logger:error("Invalid parent for ImageLabel: %s", tostring(parent))
        return nil
    end

    logger:debug("Creating ImageLabel with parent: %s, ImageURL: %s, Position: (%d, %d)", tostring(parent.Instance), imageUrl, x, y)

    -- Create the main frame
    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width or 50, 0, height or 50),
        BackgroundTransparency = 1,
        ZIndex = parent.Instance.ZIndex + 1
    })

    -- Create the image
    local image = Utilities.createInstance("ImageLabel", {
        Parent = frame,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, width or 50, 0, height or 50),
        BackgroundTransparency = 1,
        Image = imageUrl or "",
        Visible = true,
        ZIndex = frame.ZIndex + 1
    })
    Styling:Apply(image, "ImageLabel")
    logger:debug("ImageLabel created: Position: %s, Size: %s, ZIndex: %d", tostring(image.Position), tostring(image.Size), image.ZIndex)

    local self = setmetatable({
        Instance = frame,
        Image = image
    }, ImageLabel)

    function self:SetImage(url)
        self.Image.Image = url
        logger:debug("Updated ImageLabel image to: %s", url)
    end

    function self:Destroy()
        self.Instance:Destroy()
        logger:info("ImageLabel destroyed")
    end

    return self
end

return ImageLabel
