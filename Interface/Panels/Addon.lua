local Addon = HideUI:NewModule("Addon", "AceEvent-3.0")

function Addon:OnEnable()
    self:RegisterMessage("HIDEUI_PANEL_CHANGED", "OnEnter")
end

function Addon:OnEnter(event, panel)
    if panel ~= "Addon" then return end
    print("Addon")
end

function Addon:Refresh()
end

function Addon:TurnOn()
end

function Addon:TurnOff()
end
