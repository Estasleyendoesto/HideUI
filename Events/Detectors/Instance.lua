local _, ns = ...
local Instance = gUI:NewModule("InstanceDetector", "AceEvent-3.0")
Instance:SetDefaultModuleState(false)

function Instance:OnEnable()
    self.lastState = false
    -- Eventos de carga y cambio de mapa
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateInstance")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateInstance")
end

function Instance:OnDisable()
    self:UnregisterAllEvents()
    self.lastState = false
end

-- Detecta si el jugador está dentro de una instancia y qué tipo es
function Instance:UpdateInstance(force)
    local inInst, iType = IsInInstance()
    local currentState = inInst or false

    if force or currentState ~= self.lastState then
        self.lastState = currentState
        
        -- Enviamos iType como 'extra' para gestión de prioridades en Events.lua
        gUI:GetModule("Events"):RegisterEvent("INSTANCE", currentState, iType)
    end
end

function Instance:Refresh()
    self:UpdateInstance(true)
end