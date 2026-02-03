local _, ns = ...
local Mount = gUI:NewModule("MountDetector", "AceEvent-3.0")
Mount:SetDefaultModuleState(false)

function Mount:OnEnable()
    self.lastState = false
    self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED", "UpdateMount")
    self:RegisterEvent("UNIT_ENTERED_VEHICLE", "UpdateMount")
    self:RegisterEvent("UNIT_EXITED_VEHICLE", "UpdateMount")
    self:RegisterEvent("PLAYER_CONTROL_LOST", "UpdateMount")
    self:RegisterEvent("PLAYER_CONTROL_GAINED", "UpdateMount")
    self:UpdateMount()
end

function Mount:OnDisable()
    self:UnregisterAllEvents()
    self.lastState = false
end

function Mount:UpdateMount()
    local isMounted = IsMounted()
    local inVehicle = UnitInVehicle("player")

    local currentState = (isMounted or inVehicle) or false

    if currentState ~= self.lastState then
        self.lastState = currentState
        self:SendMessage("GHOSTUI_EVENT", "MOUNT", currentState)
    end
end