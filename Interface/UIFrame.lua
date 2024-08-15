local UIFrame = HideUI:NewModule("UIFrame")
local Menu

local MENU_NAME = "Frames"

function UIFrame:OnInitialize()
    Menu = HideUI:GetModule("Menu")
end

function UIFrame:OnEnable()
    self:Create()
end

function UIFrame:Create()
    local parent = Menu
    local frame = CreateFrame("Frame", "HideUI" .. MENU_NAME .. "Frame", parent.frame)
    frame.name = MENU_NAME
    frame.parent = parent.name
    
    local category = Settings.RegisterVerticalLayoutSubcategory(parent.category, MENU_NAME)
    
    self.frame = frame
    self.category = category
end