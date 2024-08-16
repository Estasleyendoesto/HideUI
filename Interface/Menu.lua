local Menu = HideUI:NewModule("Menu")
local General

local MENU_NAME = "HideUI"

function Menu:OnInitialize()
    General = HideUI:GetModule("General")
end

function Menu:OnEnable()
    self:Create()
    
    -- HideUI:EnableModule("Welcome")
    HideUI:EnableModule("General")
    -- HideUI:EnableModule("UIFrame")
    -- HideUI:EnableModule("Community")

    self:UpdateUI()
end

function Menu:UpdateUI()
    General:UpdateUI()
end

function Menu:Create()
    local parent = UIParent
    local frame = CreateFrame("Frame", "HideUI" .. MENU_NAME .. "Frame", parent)
    frame.name = MENU_NAME

    local category, layout = Settings.RegisterCanvasLayoutCategory(frame, MENU_NAME)
    Settings.RegisterAddOnCategory(category)

    self.frame = frame
    self.category = category
    self.layout = layout
end