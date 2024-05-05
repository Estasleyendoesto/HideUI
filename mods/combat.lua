local Combat_mod = HideUI:NewModule("Combat_mod", "AceEvent-3.0")
local Core_mod

function Combat_mod:OnInitialize()
    --Load Modules
    Core_mod = HideUI:GetModule("Core_mod")
end

function Combat_mod:OnEnable()
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEnterCombat")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnLeaveCombat")
end

function Combat_mod:OnDisable()
    self:UnregisterEvent("PLAYER_REGEN_DISABLED")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

function Combat_mod:OnEnterCombat()
    print("Has entrado en combate")
end

function Combat_mod:OnLeaveCombat()
    print("Has salido de combate")
end
