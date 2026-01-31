local About = HideUI:NewModule("About", "AceEvent-3.0")
local Utils = HideUI:GetModule("Utils")

-- Widgets
local MainFrame   = HideUI:GetModule("MainFrame") 

-- Panel Name
local PANEL_NAME = "About"

function About:OnEnable()
    self:RegisterMessage("HIDEUI_PANEL_CHANGED", "OnEnter")
end

function About:OnEnter(_, panel)
    if panel == PANEL_NAME then self:Draw() end
end

function About:Draw()
    MainFrame:ClearAll()

    print("About Draw")

    -- ...

    Utils:VStack(MainFrame.Content)
end
