local Combat = HideUI:NewModule("Combat", "AceEvent-3.0")

local COMBAT_END_DELAY = 1

function Combat:OnEnable()
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEnterCombat")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnLeaveCombat")
end

function Combat:OnDisable()
    self:UnregisterEvent("PLAYER_REGEN_DISABLED")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:SendMessage("PLAYER_COMBAT_STATE_CHANGED", false)
end

function Combat:OnEnterCombat() --PLAYER_REGEN_DISABLED
    self:SendMessage("PLAYER_COMBAT_STATE_CHANGED", true)
end

function Combat:OnLeaveCombat() --PLAYER_REGEN_ENABLED
    C_Timer.After(COMBAT_END_DELAY, function()
        self:SendMessage("PLAYER_COMBAT_STATE_CHANGED", false)
    end)
end