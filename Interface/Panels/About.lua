local About = HideUI:NewModule("About", "AceEvent-3.0")
local Utils = HideUI:GetModule("Utils")

function About:OnEnable()
    self:RegisterMessage("HIDEUI_PANEL_CHANGED", "OnEnter")
end

function About:OnEnter(event, panel)
    if panel == "About" then
        self:Draw()
    end
end

function About:Refresh()
    local MainFrame = HideUI:GetModule("MainFrame")
    if MainFrame.frame:IsVisible() and self.isOpen then
        self:Draw()
    end
end

function About:Draw()
    local MainFrame   = HideUI:GetModule("MainFrame")   

    self.isOpen = true
    MainFrame:ClearAll()

    -- ...

    Utils:VStack(MainFrame.Content)
end
