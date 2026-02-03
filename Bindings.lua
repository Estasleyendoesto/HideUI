local _, ns = ...

function GhostUI_Toggle()
    local db = gUI:GetModule("Database", true)
    local co = gUI:GetModule("Commands", true)
    if not db or not co then return end
    co:SetAddonState(not db:GetGlobals().addonEnabled)
end