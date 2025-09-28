-- CensuraG/src/components/grid.lua (fixed)
local Config = _G.CensuraG.Config

return function(parent)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations

    local GridFrame = Instance.new("Frame", parent)
    GridFrame.Name = "ContentGrid"
    GridFrame.Size = UDim2.new(1, -2 * Config.Math.Padding, 1, -30 - Config.Math.Padding) -- Adjust for title bar and padding
    GridFrame.Position = UDim2.new(0, Config.Math.Padding, 0, Config.Math.Padding) -- Position with padding
    GridFrame.BackgroundTransparency = 1
    GridFrame.BackgroundColor3 = theme.PrimaryColor
    GridFrame.BorderSizePixel = 0
    GridFrame.ClipsDescendants = false -- Allow items to be visible outside the grid (for dropdowns)
    
    -- Use UIListLayout for better control over positioning
    local ListLayout = Instance.new("UIListLayout", GridFrame)
    ListLayout.Padding = UDim.new(0, Config.Math.ElementSpacing)
    ListLayout.FillDirection = Enum.FillDirection.Vertical
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Add padding
    local Padding = Instance.new("UIPadding", GridFrame)
    Padding.PaddingTop = UDim.new(0, Config.Math.Padding)
    Padding.PaddingBottom = UDim.new(0, Config.Math.Padding)
    Padding.PaddingLeft = UDim.new(0, Config.Math.Padding)
    Padding.PaddingRight = UDim.new(0, Config.Math.Padding)
    
    -- Animation
    _G.CensuraG.AnimationManager:Tween(GridFrame, {BackgroundTransparency = 0}, animConfig.FadeDuration)

    local Grid = {
        Instance = GridFrame,
        Layout = ListLayout,
        ComponentCount = 0,
        MaxContentHeight = 0,
        AddComponent = function(self, component)
            if component and component.Instance then
                component.Instance.Parent = self.Instance
                component.Instance.LayoutOrder = self.ComponentCount
                self.ComponentCount = self.ComponentCount + 1
                _G.CensuraG.Logger:info("Added component to grid")
                
                -- Calculate the current content height
                local contentHeight = 0
                for _, child in ipairs(self.Instance:GetChildren()) do
                    if child:IsA("GuiObject") and not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
                        contentHeight = contentHeight + child.AbsoluteSize.Y + Config.Math.ElementSpacing
                    end
                end
                
                -- Store the maximum height for window sizing
                self.MaxContentHeight = contentHeight
                
                -- Signal the window to update size
                self.Instance:SetAttribute("ContentHeight", self.MaxContentHeight)
            else
                _G.CensuraG.Logger:warn("Invalid component provided to grid")
            end
        end,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("grid", self.Instance)
        end,
        GetContentHeight = function(self)
            return self.MaxContentHeight
        end
    }

    _G.CensuraG.Logger:info("Grid created")
    return Grid
end
