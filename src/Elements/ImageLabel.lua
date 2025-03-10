-- Elements/ImageLabel.lua: Styled image label
local ImageLabel = setmetatable({}, {__index = _G.CensuraG.UIElement})
ImageLabel.__index = ImageLabel

local Utilities = _G.CensuraG.Utilities
local Styling = _G.CensuraG.Styling
local logger = _G.CensuraG.Logger

function ImageLabel.new(parent, imageUrl, x, y, width, height, options)
    options = options or {}
    if not parent or not parent.Instance then return nil end

    local frame = Utilities.createInstance("Frame", {
        Parent = parent.Instance,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, width or 50, 0, height or 50),
        BackgroundTransparency = 1,
        ZIndex = parent.Instance.ZIndex + 1
    })

    local image = Utilities.createInstance("ImageLabel", {
        Parent = frame,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = imageUrl or "",
        ZIndex = frame.ZIndex + 1
    })
    Styling:Apply(image, "ImageLabel")

    local self = setmetatable({
        Instance = frame,
        Image = image
    }, ImageLabel)

    function self:SetImage(url)
        self.Image.Image = url
        logger:debug("ImageLabel updated to: %s", url)
    end

    function self:Destroy()
        self.Instance:Destroy()
        logger:info("ImageLabel destroyed")
    end

    return self
end

return ImageLabel
