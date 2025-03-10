-- Core/ZIndexManager.lua
-- Centralized Z-index management for CensuraG

local ZIndexManager = {}
local logger = _G.CensuraG.Logger
local EventManager = _G.CensuraG.EventManager

ZIndexManager.BaseZIndex = 100 -- Minimum Z-index, above Roblox default UI
ZIndexManager.CurrentZIndex = ZIndexManager.BaseZIndex
ZIndexManager.Elements = {} -- Tracks elements and their Z-indexes

function ZIndexManager:Init()
    logger:info("Initializing ZIndexManager with base Z-index: %d", self.BaseZIndex)
    self.Elements = {}
    self.CurrentZIndex = self.BaseZIndex
    -- Reset all CensuraG elements to start at BaseZIndex
    if _G.CensuraG.ScreenGui then
        local function resetZIndex(obj)
            if obj:IsA("GuiObject") then
                obj.ZIndex = self.BaseZIndex
                self:RegisterElement(obj)
            end
            for _, child in ipairs(obj:GetChildren()) do
                resetZIndex(child)
            end
        end
        resetZIndex(_G.CensuraG.ScreenGui)
    end
    logger:debug("ZIndexManager initialized")
    return self
end

function ZIndexManager:RegisterElement(element)
    if not element or not element:IsA("GuiObject") then
        logger:warn("Invalid element for registration in ZIndexManager")
        return nil
    end
    local id = tostring(element) -- Use element's memory address as unique ID
    if not self.Elements[id] then
        self.Elements[id] = { Element = element, BaseZIndex = element.ZIndex, RelativeZIndex = 0 }
        logger:debug("Registered element %s with base Z-index: %d", element.Name, element.ZIndex)
    end
    return id
end

function ZIndexManager:BringToFront(element)
    if not element or not element:IsA("GuiObject") then
        logger:warn("Invalid element for BringToFront")
        return false
    end
    local id = tostring(element)
    if not self.Elements[id] then
        self:RegisterElement(element)
    end
    self.CurrentZIndex = self.CurrentZIndex + 1
    local elemData = self.Elements[id]
    elemData.RelativeZIndex = self.CurrentZIndex - elemData.BaseZIndex
    element.ZIndex = self.CurrentZIndex
    
    -- Update all children recursively
    local function updateChildren(obj)
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("GuiObject") then
                local childId = tostring(child)
                if not self.Elements[childId] then
                    self:RegisterElement(child)
                end
                self.Elements[childId].RelativeZIndex = elemData.RelativeZIndex + (child.ZIndex - elemData.BaseZIndex)
                child.ZIndex = self.Elements[childId].BaseZIndex + self.Elements[childId].RelativeZIndex
                updateChildren(child)
            end
        end
    end
    updateChildren(element)
    
    logger:debug("Brought %s to front with Z-index: %d", element.Name, self.CurrentZIndex)
    EventManager:FireEvent("ZIndexChanged", element, self.CurrentZIndex)
    return true
end

function ZIndexManager:SetZIndex(element, zIndex)
    if not element or not element:IsA("GuiObject") then
        logger:warn("Invalid element for SetZIndex")
        return false
    end
    local id = tostring(element)
    if not self.Elements[id] then
        self:RegisterElement(element)
    end
    local elemData = self.Elements[id]
    elemData.RelativeZIndex = zIndex - elemData.BaseZIndex
    element.ZIndex = zIndex
    
    -- Update children
    local function updateChildren(obj)
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("GuiObject") then
                local childId = tostring(child)
                if not self.Elements[childId] then
                    self:RegisterElement(child)
                end
                self.Elements[childId].RelativeZIndex = elemData.RelativeZIndex + (child.ZIndex - elemData.BaseZIndex)
                child.ZIndex = self.Elements[childId].BaseZIndex + self.Elements[childId].RelativeZIndex
                updateChildren(child)
            end
        end
    end
    updateChildren(element)
    
    self.CurrentZIndex = math.max(self.CurrentZIndex, zIndex)
    logger:debug("Set Z-index of %s to %d", element.Name, zIndex)
    return true
end

function ZIndexManager:GetZIndex(element)
    local id = tostring(element)
    if self.Elements[id] then
        return self.Elements[id].BaseZIndex + self.Elements[id].RelativeZIndex
    end
    return element.ZIndex
end

function ZIndexManager:ResetZIndex(element)
    local id = tostring(element)
    if self.Elements[id] then
        local elemData = self.Elements[id]
        elemData.RelativeZIndex = 0
        element.ZIndex = elemData.BaseZIndex
        local function resetChildren(obj)
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("GuiObject") then
                    local childId = tostring(child)
                    if self.Elements[childId] then
                        self.Elements[childId].RelativeZIndex = 0
                        child.ZIndex = self.Elements[childId].BaseZIndex
                        resetChildren(child)
                    end
                end
            end
        end
        resetChildren(element)
        logger:debug("Reset Z-index of %s to base: %d", element.Name, elemData.BaseZIndex)
        return true
    end
    return false
end

function ZIndexManager:GetNextZIndex()
    self.CurrentZIndex = self.CurrentZIndex + 1
    logger:debug("Generated next Z-index: %d", self.CurrentZIndex)
    return self.CurrentZIndex
end

function ZIndexManager:Cleanup()
    self.Elements = {}
    self.CurrentZIndex = self.BaseZIndex
    logger:info("ZIndexManager cleaned up")
end

return ZIndexManager
