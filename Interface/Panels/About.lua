local About = HideUI:NewModule("About", "AceEvent-3.0")

function About:OnEnable()
    self:RegisterMessage("HIDEUI_PANEL_CHANGED", "OnEnter")
end

function About:OnEnter(event, panel)
    if panel ~= "About" then return end
    print("About")
end
