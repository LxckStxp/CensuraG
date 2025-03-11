-- CensuraG/src/components/grid.lua (updated for dynamic sizing)
local Config = _G.CensuraG.Config

return function(parent)
    local theme = Config:GetTheme()
    local animConfig = Config.Animations

    local GridFrame = Instance.new("Frame", parent)
    GridFrame.Size = UDim2.new(1, -2 * Config.Math.Padding, 1, -30 - Config.Math.Padding) -- Adjust for title bar and padding
    GridFrame.Position = UDim2.new(0, Config.Math.Padding, 0, 30 + Config.Math.Padding) -- Below title bar
    GridFrame.BackgroundTransparency = 1
    GridFrame.BackgroundColor3 = theme.PrimaryColor
    GridFrame.BorderSizePixel = 0
    GridFrame.BackgroundTransparency = 1 -- Start hidden for animation
    GridFrame.Name = "ContentGrid"
    GridFrame.AutomaticSize = Enum.AutomaticSize.Y -- Allow vertical expansion

    local GridLayout = Instance.new("UIGridLayout", GridFrame)
    GridLayout.CellSize = UDim2.new(0, 150, 0, 50) -- Consistent size for components
    GridLayout.CellPadding = UDim2.new(0, Config.Math.ElementSpacing, 0, Config.Math.ElementSpacing)
    GridLayout.StartCorner = Enum.StartCorner.TopLeft
    GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    GridLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Add a UIListLayout to enable automatic sizing
    local ListLayout = Instance.new("UIListLayout", GridFrame)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, Config.Math.ElementSpacing)
    ListLayout.FillDirection = Enum.FillDirection.Vertical
    ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    
    -- Set the active layout to use
    GridLayout.Parent = nil -- Disable grid layout initially
    ListLayout.Parent = GridFrame -- Use list layout by default

    -- Animation
    _G.CensuraG.AnimationManager:Tween(GridFrame, {BackgroundTransparency = 0}, animConfig.FadeDuration)

    local Grid = {
        Instance = GridFrame,
        Layout = ListLayout, -- Use the list layout for better automatic sizing
        GridLayout = GridLayout, -- Keep reference to grid layout
        ComponentCount = 0,
        AddComponent = function(self, component)
            if component and component.Instance then
                component.Instance.Parent = self.Instance
                component.Instance.LayoutOrder = self.ComponentCount
                self.ComponentCount = self.ComponentCount + 1
                _G.CensuraG.Logger:info("Added component to grid")
                
                -- Update the parent window size if possible
                local window = self.Instance.Parent
                if window and window:FindFirstChild("ContentGrid") then
                    if window.Resize then
                        window:Resize()
                    end
                end
            else
                _G.CensuraG.Logger:warn("Invalid component provided to grid")
            end
        end,
        Refresh = function(self)
            _G.CensuraG.Methods:RefreshComponent("grid", self.Instance)
            -- Force layout to update
            if self.Layout.ApplyLayout then
                self.Layout:ApplyLayout()
            end
        end,
        SetLayoutMode = function(self, mode)
            if mode == "grid" then
                self.Layout.Parent = nil
                self.GridLayout.Parent = self.Instance
                self.Layout = self.GridLayout
            elseif mode == "list" then
                self.GridLayout.Parent = nil
                self.ListLayout.Parent = self.Instance
                self.Layout = self.ListLayout
            end
            self:Refresh()
        end
    }

    _G.CensuraG.Logger:info("Grid created")
    return Grid
end
