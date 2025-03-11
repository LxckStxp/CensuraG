-- CensuraG/src/components/imagelabel.lua
local Config = _G.CensuraG.Config

return function(parent, imageId)
    local animConfig = Config.Animations
    
    local Image = Instance.new("ImageLabel", parent)
    Image.Size = UDim2.new(0, 50, 0, 50)
    Image.BackgroundTransparency = 1
    Image.Image = imageId or "rbxassetid://0"
    Image.BorderSizePixel = 0
    Image.ImageTransparency = 1 -- Start hidden
    
    -- Animation
    _G.CensuraG.AnimationManager:Tween(Image, {ImageTransparency = 0}, animConfig.FadeDuration)
    
    local ImageLabel = {
        Instance = Image,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("imagelabel", self.Instance)
        end
    }
    
    _G.CensuraG.Logger:info("ImageLabel created with ID: " .. (imageId or "none"))
    return ImageLabel
end
