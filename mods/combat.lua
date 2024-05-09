local Combat_mod = HideUI:NewModule("Combat_mod", "AceEvent-3.0")
local DB_mod

local OnHide_mod
local Chat_mod

function Combat_mod:OnInitialize()
    DB_mod = HideUI:GetModule("DB_mod")
    OnHide_mod = HideUI:GetModule("OnHide_mod")
    Chat_mod = HideUI:GetModule("Chat_mod")
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
    print("Has entrado en combate", DB_mod:Find("isCombat"))


    --FUNCIONA PERO REQUIERE FADE

    OnHide_mod:DisableMouseOver()
    OnHide_mod:UpdateGlobalTransparency(1)

    
    Chat_mod:DisableMouseOver()
    Chat_mod:UpdateGlobalTransparency(1)
    Chat_mod:RestoreTabFrames(self.default_alpha) --Default (10.2.6)
    Chat_mod:UnhookAll()
    
    --Reset Fade Out Alpha
    Chat_mod.isFadedIn = true
    Chat_mod:FadeOutChats(1)


end

function Combat_mod:CombatEnd()
    print("Has salido de combate", DB_mod:Find("isCombat"))


    --FUNCIONA PERO REQUIERE FADE

    OnHide_mod:UpdateGlobalTransparency(DB_mod:Find("globalOpacity"))
    OnHide_mod:CollectFrames()
    OnHide_mod:CheckMouseOverState()

    
    Chat_mod:ChatboxesUpdateTrigger_Hook()
    Chat_mod:CheckMouseOverState()
    Chat_mod:UpdateGlobalTransparency()


    

end