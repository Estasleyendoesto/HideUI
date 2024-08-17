local Community = HideUI:NewModule("Community")
local UIManager

local MENU_NAME = "Community"

function Community:OnInitialize()
    UIManager = HideUI:GetModule("UIManager")
end

function Community:OnEnable()
    self:Create()
end

function Community:Create()
    local parent = UIManager
    local frame = CreateFrame("Frame", "HideUI" .. MENU_NAME .. "Frame", parent.frame)
    frame.name = MENU_NAME
    frame.parent = parent.name
    
    local category = Settings.RegisterVerticalLayoutSubcategory(parent.category, MENU_NAME)
    
    self.frame = frame
    self.category = category
end