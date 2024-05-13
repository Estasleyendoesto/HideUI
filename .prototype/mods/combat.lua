local Combat_mod = HideUI:NewModule("Combat_mod", "AceEvent-3.0")
local DB_mod
local AFK_mod

local FrameHandler_mod
local Chat_mod

function Combat_mod:OnInitialize()
    DB_mod = HideUI:GetModule("DB_mod")
    FrameHandler_mod = HideUI:GetModule("FrameHandler_mod")
    Chat_mod = HideUI:GetModule("Chat_mod")
    AFK_mod = HideUI:GetModule("AFK_mod")

    self.combatEndDelay = 1 --Tiempo que tarda en volver todo a la normalidad
end

function Combat_mod:OnEnable()
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEnterCombat")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnLeaveCombat")

    if UnitAffectingCombat("player") then
        self:OnEnterCombat()
    end
end

function Combat_mod:OnDisable()
    self:UnregisterEvent("PLAYER_REGEN_DISABLED")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")

    if DB_mod:Find("isEnabled") then
        FrameHandler_mod:Enable()
        Chat_mod:Enable()
    end
end

function Combat_mod:OnEnterCombat()
    if DB_mod:Find("isCombat") then
        self:CombatStart()
    end
end

function Combat_mod:OnLeaveCombat()
    if DB_mod:Find("isCombat") then
        self:CombatEnd()
    end
end

function Combat_mod:CombatStart()
    FrameHandler_mod:Disable()
    Chat_mod:Disable()
    self.inCombat = true
end

function Combat_mod:CombatEnd()
    if self.combatEndDelay then
        C_Timer.After(self.combatEndDelay, function()
            FrameHandler_mod:Enable()
            Chat_mod:Enable()
            self.inCombat = false
        end)
    end    
end
