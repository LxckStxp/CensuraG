-- CensuraG/src/components/imagelabel.lua
local Config = _G.CensuraG.Config

return function(parent, imageId)
    local Image = Instance.new("ImageLabel", parent)
    Image.Size = UDim2.new(0, 50, 0, 50)
    Image.BackgroundTransparency = 1
    Image.Image = imageId or "rbxassetid://0" -- Default to empty if no ID provided
    Image.BorderSizePixel = 0
    
    _G.CensuraG.Logger:info("ImageLabel created with ID: " .. (imageId or "none"))
    return Image
end
