local _, ns = ...
local Combat = gUI:NewModule("CombatDetector", "AceEvent-3.0")
Combat:SetDefaultModuleState(false)

function Combat:OnEnable()
    self.lastState = false
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateCombat")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateCombat")
    self:RegisterEvent("UNIT_COMBAT", "FilterUnitCombat")
    self:RegisterEvent("PET_BATTLE_OPENING_START", "UpdateCombat")
    self:RegisterEvent("PET_BATTLE_OVER", "UpdateCombat")
    self:UpdateCombat()
end

function Combat:OnDisable()
    self:UnregisterAllEvents()
    self.lastState = false
end

function Combat:FilterUnitCombat(event, unit)
    if unit == "player" then
        self:UpdateCombat()
    end
end

function Combat:UpdateCombat()
    local inCombat = UnitAffectingCombat("player") 
    local inPetBattle = (C_PetBattles and C_PetBattles.IsInBattle())
    
    local currentState = (inCombat or inPetBattle) or false

    if currentState ~= self.lastState then
        self.lastState = currentState
        self:SendMessage("GHOSTUI_EVENT", "COMBAT", currentState)
    end
end