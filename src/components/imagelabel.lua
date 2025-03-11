-- CensuraG/src/components/imagelabel.lua
local Config = _G.CensuraG.Config

return function(parent, imageId)
    local theme = Config:GetTheme()
    local Image = Instance.new("ImageLabel", parent)
    Image.Size = UDim2.new(0, 50, 0, 50)
    Image.BackgroundTransparency = 1
    Image.Image = imageId or "rbxassetid://0"
    Image.BorderSizePixel = 0
    Image.ImageTransparency = 1 -- Start invisible
    
    -- Fade-in animation
    _G.CensuraG.AnimationManager:Tween(Image, {
        ImageTransparency = 0
    }, Config.Animations.FadeDuration)
    
    _G.CensuraG.Logger:info("ImageLabel created with ID: " .. (imageId or "none"))
    return Image
end
