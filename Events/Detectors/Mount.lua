local _, ns = ...
local Mount = gUI:NewModule("MountDetector", "AceEvent-3.0")
Mount:SetDefaultModuleState(false)

function Mount:OnEnable()
    self.lastState = false
    -- Eventos de montura y vehículos
    self:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED", "UpdateMount")
    self:RegisterEvent("UNIT_ENTERED_VEHICLE", "UpdateMount")
    self:RegisterEvent("UNIT_EXITED_VEHICLE", "UpdateMount")
    -- Control del jugador (útil para taxis o estados especiales)
    self:RegisterEvent("PLAYER_CONTROL_LOST", "UpdateMount")
    self:RegisterEvent("PLAYER_CONTROL_GAINED", "UpdateMount")
end

function Mount:OnDisable()
    self:UnregisterAllEvents()
    self.lastState = false
end

-- Detecta si el jugador está montado o dentro de un vehículo
function Mount:UpdateMount(force)
    local isMounted = IsMounted()
    local inVehicle = UnitInVehicle("player")

    local currentState = (isMounted or inVehicle) or false

    if force or currentState ~= self.lastState then
        self.lastState = currentState
        -- Llamada directa para evitar el overhead de AceEvent
        gUI:GetModule("Events"):RegisterEvent("MOUNT", currentState)
    end
end

function Mount:Refresh()
    self:UpdateMount(true)
end