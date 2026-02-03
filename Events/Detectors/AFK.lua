local _, ns = ...
local AFK = gUI:NewModule("AFKDetector", "AceEvent-3.0")
AFK:SetDefaultModuleState(false)

function AFK:OnEnable()
    self.lastState = false
    self:RegisterEvent("PLAYER_FLAGS_CHANGED", "UpdateAFK")
    self:UpdateAFK()
end

function AFK:OnDisable()
    self:UnregisterAllEvents()
    self.lastState = false
end

function AFK:UpdateAFK()
    local currentState = UnitIsAFK("player")
    if currentState ~= self.lastState then
        self.lastState = currentState
        self:SendMessage("GHOSTUI_EVENT", "AFK", currentState)
    end
end