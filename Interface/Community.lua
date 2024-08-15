local Community = HideUI:NewModule("Community")
local Menu

local MENU_NAME = "Community"

function Community:OnInitialize()
    Menu = HideUI:GetModule("Menu")
end

function Community:OnEnable()
    self:Create()
end

function Community:Create()
    local parent = Menu
    local frame = CreateFrame("Frame", "HideUI" .. MENU_NAME .. "Frame", parent.frame)
    frame.name = MENU_NAME
    frame.parent = parent.name
    
    local category = Settings.RegisterVerticalLayoutSubcategory(parent.category, MENU_NAME)
    
    self.frame = frame
    self.category = category
end