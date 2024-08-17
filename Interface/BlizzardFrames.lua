local BlizzardFrames = HideUI:NewModule("BlizzardFrames")
local UIManager

local MENU_NAME = "Frames"

function BlizzardFrames:OnInitialize()
    UIManager = HideUI:GetModule("UIManager")
end

function BlizzardFrames:OnEnable()
    self:Create()
end

function BlizzardFrames:Create()
    local parent = UIManager
    local frame = CreateFrame("Frame", "HideUI" .. MENU_NAME .. "Frame", parent.frame)
    frame.name = MENU_NAME
    frame.parent = parent.name
    
    local category = Settings.RegisterVerticalLayoutSubcategory(parent.category, MENU_NAME)
    
    self.frame = frame
    self.category = category
end