local _, ns = ...
local AFK = gUI:NewModule("AFKDetector", "AceEvent-3.0")
AFK:SetDefaultModuleState(false)

function AFK:OnEnable()
    self.lastState = false
    self:RegisterEvent("PLAYER_FLAGS_CHANGED", "UpdateAFK")
end

function AFK:OnDisable()
    self:UnregisterAllEvents()
    self.lastState = false
end

-- Procesa el estado AFK y lo comunica directamente al gestor de eventos
function AFK:UpdateAFK(force)
    local currentState = UnitIsAFK("player") or false
    
    if force or currentState ~= self.lastState then
        self.lastState = currentState
        
        -- Invocación directa para evitar la latencia y fallos de registro de AceEvent
        gUI:GetModule("Events"):RegisterEvent("AFK", currentState)
    end
end

function AFK:Refresh()
    self:UpdateAFK(true)
end