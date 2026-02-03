local _, ns = ...
local Combat = gUI:NewModule("CombatDetector", "AceEvent-3.0")
Combat:SetDefaultModuleState(false)

function Combat:OnEnable()
    self.lastState = false
    -- Eventos principales de regeneración y combate
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateCombat")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateCombat")
    self:RegisterEvent("UNIT_COMBAT", "FilterUnitCombat")
    -- Soporte para duelos de mascotas
    self:RegisterEvent("PET_BATTLE_OPENING_START", "UpdateCombat")
    self:RegisterEvent("PET_BATTLE_OVER", "UpdateCombat")
end

function Combat:OnDisable()
    self:UnregisterAllEvents()
    self.lastState = false
end

function Combat:FilterUnitCombat(_, unit)
    if unit == "player" then self:UpdateCombat() end
end

-- Determina si el jugador está en combate real o duelo de mascotas
function Combat:UpdateCombat(force)
    local inCombat = UnitAffectingCombat("player") 
    local inPetBattle = C_PetBattles and C_PetBattles.IsInBattle()
    
    local currentState = (inCombat or inPetBattle) or false

    if force or currentState ~= self.lastState then
        self.lastState = currentState
        -- Comunicación directa al gestor de eventos
        gUI:GetModule("Events"):RegisterEvent("COMBAT", currentState)
    end
end

function Combat:Refresh()
    self:UpdateCombat(true)
end