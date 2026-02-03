local _, ns = ...
local Instance = gUI:NewModule("InstanceDetector", "AceEvent-3.0")
Instance:SetDefaultModuleState(false)

function Instance:OnEnable()
    self.lastState = false
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateInstance")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateInstance")
    self:UpdateInstance()
end

function Instance:OnDisable()
    self:UnregisterAllEvents()
    self.lastState = false
end

function Instance:UpdateInstance()
    local inInst, iType = IsInInstance()
    local currentState = inInst or false

    if currentState ~= self.lastState then
        self.lastState = currentState
        self:SendMessage("GHOSTUI_EVENT", "INSTANCE", currentState, iType)
    end
end