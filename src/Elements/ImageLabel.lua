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

    local image = Utilities.createInstance("ImageLabel", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width or 50, 0, height or 50),
        BackgroundTransparency = 1,
        Image = imageUrl or "",
        Visible = true,
        ZIndex = options.ZIndex or 3
    })
    Styling:Apply(image, "ImageLabel")
    logger:debug("ImageLabel created: Position: %s, Size: %s, ZIndex: %d", tostring(image.Position), tostring(image.Size), image.ZIndex)

    local self = setmetatable({
        Instance = image
    }, ImageLabel)

    return self
end

function ImageLabel:SetImage(url)
    self.Instance.Image = url
    logger:debug("Updated ImageLabel image to: %s", url)
end

function ImageLabel:Destroy()
    self.Instance:Destroy()
    logger:info("ImageLabel destroyed")
end

return ImageLabel
