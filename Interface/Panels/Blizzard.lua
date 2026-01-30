local Blizzard = HideUI:NewModule("Blizzard", "AceEvent-3.0")

function Blizzard:OnEnable()
    self:RegisterMessage("HIDEUI_PANEL_CHANGED", "OnEnter")
end

function Blizzard:OnEnter(event, panel)
    if panel ~= "Blizzard" then return end
    print("Blizzard")
end

function Blizzard:Refresh()
end

function Blizzard:TurnOn()
end

function Blizzard:TurnOff()
end
